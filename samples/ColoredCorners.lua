--- Colored corners demo.

--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
--

-- Standard library imports --
local floor = math.floor
local max = math.max
local min = math.min
local random = math.random

-- Modules --
local button = require("ui.Button")
local flow = require("graph_ops.flow")
local image_patterns = require("ui.patterns.image")
local layout = require("utils.Layout")
local long_running = require("samples.utils.LongRunning")
local scenes = require("utils.Scenes")

-- Corona globals --
local display = display
local native = native
local system = system

-- Corona modules --
local composer = require("composer")
local widget = require("widget")

-- Colored corners demo scene --
local Scene = composer.newScene()

--
function Scene:create (event)
	event.params.boilerplate(self.view)
end

Scene:addEventListener("create")

--[[
	From "An Alternative for Wang Tiles: Colored Edges versus Colored Corners":

	"With the backtracking algorithm, we are able to compute Wang and corner tile packings for
	two, three, and four colors. A solution for C colors can often be found more quickly by
	starting from a solution of C − 1 colors. This way, a recursive tile packing is obtained.
	A recursive corner tile packing for four colors is shown in Figure 9. Some of these tile
	packings took almost one year of CPU time to compute on a cluster with 400 2.4 GHz CPUs.
	More solutions and a description of the implementation of our parallel backtracking
	algorithm can be found in Lagae and Dutré [2006b]."

	Corner weights:

	1 --- 16
	|      |
	2 ---  4

	To obtain the numeric tile values shown in the paper, the numeric values associated with a
	given tile's colors are multiplied by the corresponding corner weights and summed.
]]

-- Numeric values of red, yellow, green, blue --
local R, Y, G, B = 0, 1, 2, 3

-- --
local Strokes = { { 1, 0, 0 }, { 1, 1, 0 }, { 0, 1, 0 }, { 0, 0, 1 } }

-- Recursive tile packing --
local Colors = {
	R, R, Y, R, R, G, R, G, G, R, B, B, R, B, R, B, -- N.B. Last row, column wrap
	G, B, G, B, Y, B, B, Y, B, G, B, G, Y, G, B, B,
	B, R, B, Y, B, G, B, Y, B, R, B, Y, B, Y, B, Y,
	G, G, G, B, Y, Y, Y, G, B, R, B, R, B, G, Y, Y,
	G, B, G, B, B, B, G, B, B, Y, B, B, G, B, G, B,
	Y, R, G, Y, G, Y, G, G, R, B, B, B, B, G, R, G,
	B, G, B, B, B, R, B, Y, B, Y, B, R, B, G, B, G,
	R, R, Y, R, R, G, R, G, G, R, Y, B, R, Y, G, G,
	Y, G, G, G, G, G, R, G, G, Y, B, R, B, Y, B, B,
	Y, G, R, G, Y, G, G, Y, R, Y, Y, G, Y, R, G, G,
	Y, Y, Y, G, Y, R, Y, Y, G, Y, B, R, B, B, R, B,
	G, Y, G, Y, G, Y, G, R, G, G, R, R, Y, Y, R, G,
	R, R, Y, R, R, G, R, G, R, R, B, G, B, Y, B, B,
	Y, R, Y, Y, Y, R, Y, Y, G, Y, Y, R, R, Y, R, Y,
	R, Y, Y, Y, R, G, R, G, G, R, B, Y, B, R, B, B,
	R, R, R, Y, R, R, R, Y, Y, R, R, R, R, Y, R, G
}

-- --
local Exemplars = {}

--
local function GetExemplar (index)
	return Exemplars[Colors[index] + 1]
end

--
local function Synthesize (n, tdim)
	local row1, row2, dim = #Colors - 15, 1, n^2
	local y = tdim * (dim - 1)

	for _ = 1, dim do
		local x = 0

		for j = 1, dim do
			local offset1, offset2 = j - 1, j < 16 and j or 0

			local ul, ur = GetExemplar(row1 + offset1), GetExemplar(row1 + offset2)
			local ll, lr = GetExemplar(row2 + offset1), GetExemplar(row2 + offset2)

			-- 	 Solve patch
			--     Build diamond grid - how to handle edges? For the rest, just connect most of the 4 sides... (maybe use a LUT)
			--     Run max flow over it
			--     Replace colors inside the cut
			--     Tidy up the seam (once implemented...)

			x = x + tdim
		end

		row1, row2, y = row1 - 16, row1, y - tdim
	end
end

-- --
local MaxSize = system.getInfo("maxTextureSize")

-- --
local NumColors = "# Colors: %i"

-- --
local Size = "Maximum tile size: %i"

-- --
-- N.B. only a quarter of each exemplar is used per tile, so any valid dimension must be a
-- multiple of 2. (For similar reasons, the maximum dimension must be a multiple of 4.) In
-- addition, this constraint ensures symmetry for the diamond-shaped patch.
local MinDim = 16

--
local function ToSize (num)
	return (2 + num) * MinDim
end

-- --
local function SizeStepper (num_colors, left, ref, size_text)
	local max_steps = floor((MaxSize / 2^num_colors - MinDim) / MinDim) - 1

	size_text.text = Size:format(ToSize(0))

	local size_stepper = widget.newStepper{
		left = left, top = layout.Below(ref, 20), maximumValue = max_steps, timerIncrementSpeed = 250, changeSpeedAtIncrement = 3,

		onPress = function(event)
			local phase = event.phase

			if phase == "increment" or phase == "decrement" then
				size_text.text = Size:format(ToSize(event.value))
			end
		end
	}

	ref.parent:insert(size_stepper)

	return size_stepper
end

-- --
local Funcs = long_running.GetFuncs(Scene)

--
local function TextSetup (text, stepper)
	text.anchorX, text.y = 0, stepper.y

	layout.PutRightOf(text, stepper, 20)
end

--
function Scene:show (event)
	if event.phase == "did" then
		-- Add a listbox to be populated with some image choices.
		local preview, ok, colors_stepper, size_stepper

		local image_list = image_patterns.ImageList(self.view, 295, 20, {
			path = "Background_Assets", base = system.ResourceDirectory, height = 120, preview_width = 96, preview_height = 96,

			filter_info = function(_, w, h) -- Add any "big enough" images to the list.
				return w >= MinDim and h >= MinDim
			end,

			press = function(event)
				-- On the first selection, add a button to launch the next step. When fired, the selected
				-- image is read into memory; assuming that went well, the algorithm proceeds on to the
				-- energy computation step. The option to cancel is available during loading (although
				-- this is typically a quick process).
				ok = ok or button.Button(self.view, nil, preview.x, layout.Below(preview, 30), 100, 40, Funcs.Action(function()
					-- funcs.SetStatus("Loading image")

					--
					local w, h = event.listbox:GetDims()
					local tile_dim = min(w, h)

					if tile_dim % 2 ~= 0 then
						tile_dim = tile_dim - 1
					end

					tile_dim = min(tile_dim, .5 * ToSize(size_stepper:getValue()))

					local px, py = preview:GetPos()
					local pw, ph = preview:GetDims()
					local fw, fh, x0, y0 = tile_dim / pw, tile_dim / ph, px - .5 * pw, py - .5 * ph
					local rw, rh = max(floor(fw), 5), max(floor(fh), 5)

					for i = 1, colors_stepper:getValue() do
						local x, y, stroke = random(0, w - tile_dim), random(0, h - tile_dim), Strokes[i]
						local rect = display.newRect(self.view, floor(x0 + x * fw), floor(y0 + y * fh), rw, rh)

						rect.strokeWidth = 2

						rect:setFillColor(0, 0)
						rect:setStrokeColor(stroke[1], stroke[2], stroke[3], .7)

						Exemplars[i] = 4 * (y * w + x)
					end

					-- Could ask if selections are ok, spread across multiple overlays
					local image = event.listbox:LoadImage(Funcs.TryToYield)

				--	cancel.isVisible = false

					if image then
					--[[
						return function()
							params.ok_x = ok.x
							params.ok_y = ok.y
							params.cancel_y = cancel.y
							params.image = image

							funcs.ShowOverlay("samples.overlay.Seams_Energy", params)
						end
					]]
						local pixels = image:GetPixels()

						for i = 1, colors_stepper:getValue() do
							local exemplar, index, ypos = {}, 1, Exemplars[i]

							for _ = 1, tile_dim do
								local xpos = ypos

								for _ = 1, tile_dim do
									local sum = pixels[xpos + 1] + pixels[xpos + 2] + pixels[xpos + 3]

									exemplar[index], xpos, index = sum, xpos + 4, index + 1
								end

								ypos = ypos + 4 * w
							end

							Exemplars[i] = exemplar
						end
					else
					--	funcs.SetStatus("Choose an image")
					end
				end), "OK")

--				cancel = cancel or buttons.Button(self.view, nil, ok.x, ok.y + 100, 100, 40, Wait, "Cancel")

--				Wait()
			end
		})

		image_list:Init()

		-- Place the preview pane relative to the listbox.
		preview = image_list:GetPreview()

		preview.x, preview.y = layout.RightOf(image_list, 85), image_list.y

		--
		local color_text, size_text

		colors_stepper = widget.newStepper{
			left = 25, top = layout.Below(image_list, 20), initialValue = 4, minimumValue = 2, maximumValue = 4,

			onPress = function(event)
				local phase = event.phase

				if phase == "increment" or phase == "decrement" then
					color_text.text = NumColors:format(event.value)

					size_stepper:removeSelf()

					local target = event.target

					size_stepper = SizeStepper(event.value, 25, target, size_text)
				end
			end
		}

		color_text = display.newText(self.view, NumColors:format(colors_stepper:getValue()), 0, 0, native.systemFont, 28)

		TextSetup(color_text, colors_stepper)

		self.view:insert(colors_stepper)

		size_text = display.newText(self.view, "", 0, 0, native.systemFont, 28)
		size_stepper = SizeStepper(2, 25, colors_stepper, size_text)

		TextSetup(size_text, size_stepper)

		-- Pick energy function? (Add one or both from paper)
		-- Way to tune the randomness? (k = .001 to 1, as in the GC paper, say)
		-- ^^^ Probably irrelevant, actually (though the stuff in the Kwatra paper would make for a nice sample itself...)
		-- Feathering / multiresolution splining options (EXTRA CREDIT)

		-- Step 1: Choose all the stuff (files, num colors, size)
		-- Step 2: Find the color patches (TODO)
		-- Step 3: Synthesize()
	end
end

Scene:addEventListener("show")

--
function Scene:hide (event)
	if event.phase == "did" then
		Funcs.Finish()
	end
end

Scene:addEventListener("hide")

return Scene
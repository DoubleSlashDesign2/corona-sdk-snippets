--- Implementation of minimum spanning trees.

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

-- Modules --
local disjoint_set = require("graph_ops.disjoint_set")

-- Exports --
local M = {}

--- DOCME
local function Kruskal (edges_weight, verts)
--[[
KRUSKAL(G):
	A = null
	foreach v in G.V:
		MAKE-SET(v)
	foreach (u, v) ordered by weight(u, v), increasing:
		if FIND-SET(u) ≠ FIND-SET(v):
			A = A union {(u, v)}
			UNION(u, v)
	return A
]]
end

--- DOCME
function M.MST (edges, verts, weights)
	return Kruskal()
end

-- Export the module.
return M
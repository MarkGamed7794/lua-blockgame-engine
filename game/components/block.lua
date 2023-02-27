-- Wrapper for a Cell/position pair.

local Cell = require "game.components.cell"
local vec2 = require "game.components.vec2"

local Block = {}

-- Returns a new Block.
function Block:new(cell, position)
    return {
        cell = cell or Cell.new(),
        position = position or vec2.new(0, 0)
    }
end

setmetatable(Block, {
    __call = Block.new
})

return Block
-- Each individual cell of a Shape or Board.

local Colour = require "game.components.colour"

local Cell = {
    mt = {
        __type = "Cell",
    }
}

-- Returns a new Cell.
function Cell:new(solid, colour, age)
    new_cell = {
        solid = solid or false,
        colour = colour or Colour(1, 1, 1),
        age = age or 0,

        isSolid = self.isSolid
    }
    setmetatable(new_cell, self.mt)
    return new_cell
end

-- Returns true if the cell is marked as solid, false otherwise.
function Cell:isSolid()
    return self.solid
end

setmetatable(Cell, {
    __call = Cell.new
})

return Cell
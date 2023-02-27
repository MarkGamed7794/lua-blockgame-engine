-- List of blocks.

Cell = require "game.components.cell"
Colour = require "game.components.colour"

local Row = {
    mt = {
        __type = "Row"
    }
}

-- Creates a new Row of Cells.
function Row:new(width, cells)
    local new_row = {
        cells = {},
        width = width,

        inBounds = Row.inBounds,
        getCell = Row.getCell,
        setCell = Row.setCell,
        isFull = Row.isFull
    }

    setmetatable(new_row, self.mt)

    return new_row
end

-- Returns true if the given position is inside of the Row, false otherwise.
function Row:inBounds(x)
    if(self.width <= 0) then return false end
    return (x >= 1 and x <= self.width)
end

-- Returns true if every position in the Row has a cell, false otherwise.
function Row:isFull()
    for x=1, self.width do
        if(not self:getCell(x)) then
            return false
        end
    end
    return true
end

-- Returns the given Cell for a position. Out-of-bounds positions return a dummy, solid Cell.
function Row:getCell(x)
    if(self:inBounds(x)) then
        return self.cells[x]
    else
        return Cell(true)
    end
end

-- Sets the Cell at a specified position in the Row.
function Row:setCell(x, cell)
    if(self:inBounds(x)) then
        self.cells[x] = copy(cell)
    else
        error("attempted to set out of bounds cell: " .. tostring(x) .. " in size [" .. self.width .. "]")
    end
end

setmetatable(Row, {
    __call = Row.new
})

return Row
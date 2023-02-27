Cell = require "game.components.cell"
Colour = require "game.components.colour"
Row = require "game.components.row"

local Board = {
    mt = {
        __type = "Board"
    }
}

function Board:new(width, height, hidden_rows, background_colour)
    local new_board = {
        rows = {},
        width = width,
        height = height + hidden_rows,
        hidden_rows = hidden_rows,
        background_colour = background_colour or Colour(0.5,0.5,0.5,0.5),
        full_rows = {},

        inBounds = Board.inBounds,
        getCell = Board.getCell,
        setCell = Board.setCell,
        removeRow = Board.removeRow,
        checkFullRows = Board.checkFullRows
    }
    
    for y=1, height + hidden_rows do
        new_board.rows[y] = Row(width)
    end

    setmetatable(new_board, self.mt)

    return new_board
end

function Board:inBounds(pos)
    if(self.width <= 0 or self.height <= 0) then return false end
    return (pos.x >= 1 and pos.x <= self.width and pos.y >= 1 and pos.y <= self.height)
end

function Board:getCell(pos)
    if(self:inBounds(pos)) then
        return self.rows[pos.y]:getCell(pos.x)
    else
        return Cell(true)
    end
end

function Board:setCell(pos, cell)
    if(self:inBounds(pos)) then
        self.rows[pos.y]:setCell(pos.x,cell)
    else
        error("attempted to set out of bounds cell: " .. tostring(pos) .. " in size [" .. self.width .. ", " .. self.height .. "]")
    end
end

function Board:removeRow(row)
    if(type(row) == "number") then
        table.remove(self.rows, row)
        table.insert(self.rows, 1, Row(self.width))
    else
        for i, row in pairs(self.rows) do
            if(row == self.rows) then
                self:removeRow(i)
                return
            end
        end
    end
end

function Board:checkFullRows()
    local full_rows = {}
    for y, row in ipairs(self.rows) do
        if(row:isFull()) then
            row.cleared = true
            table.insert(full_rows, y)
        end
    end
    self.full_rows = full_rows
    return full_rows
end

setmetatable(Board, {
    __call = Board.new
})

return Board
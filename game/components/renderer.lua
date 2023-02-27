-- Renderer class. Keeps an engine reference by default -- but all drawing operations are fully customizable. This is NOT part of the engine--use with caution.

vec2 = require "game.components.vec2"
Colour = require "game.components.colour"

local Renderer = {
    mt = {
        __type = "Renderer"
    }
}

function Renderer:new(engine, offset, scale)
    local new_renderer = {
        offset = offset or vec2(0, 0),
        scale = scale or 1,
        engine = engine,

        rectangle_coordinates = self.rectangle_coordinates,
        drawPiece = self.drawPiece,
        drawBoard = self.drawBoard,
        draw = self.draw,
        drawEngine = self.drawEngine,
        drawShapeRelativeToBoard = self.drawShapeRelativeToBoard,
        drawShape = self.drawShape,
        drawPieceQueue = self.drawPieceQueue,
        drawStatistic = self.drawStatistic
    }

    setmetatable(new_renderer, Renderer.mt)
    
    return new_renderer
end

function Renderer:rectangle_coordinates(position, offset, scale, size)
    -- Given the position, visual offset, scale, and size, returns the four corners of a rectangle that would be drawn at that position.
    local offset = offset or self.offset
    local scale = scale or self.scale
    local size = size or 1
    

    local tl = (position * scale) + offset
    local br = tl + vec2(scale * size, scale * size)
    local tr = vec2(tl.y, br.x)
    local bl = vec2(tl.x, br.y)

    return tl, tr, bl, br
end

function Renderer:drawEngine(engine, offset)
    -- Draws all the objects in an Engine. Note that this treats the offset as the *center* of the board, not the top-left corner.
    local engine = engine or self.engine
    local board_size_offset = vec2(engine.board.width * self.scale * -0.5, (engine.board.height + engine.board.hidden_rows) * -0.5 * self.scale)
    self:drawBoard(engine.board, (offset or self.offset) + board_size_offset)
    for _, piece in pairs(engine.pieces) do
        self:drawPiece(piece, vec2(0, 0), (offset or self.offset) + board_size_offset)
    end
end

function Renderer:drawShapeRelativeToBoard(shape, board, position_offset, offset, scale)
    local board_size_offset = vec2(board.width * self.scale * -0.5, (board.height + board.hidden_rows) * -0.5 * self.scale)
    self:drawShape(shape, position_offset, (offset or self.offset) + board_size_offset)
end

function Renderer:drawPiece(piece, position_offset, offset, scale)
    -- Draws a Piece to the screen. Pieces with no shape are not rendered. By default, draws the piece relative to the board at the internal scale and offset (can be overridden).
    if(not piece.shape) then return false end
    
    local block_positions = piece:getBlockPositions()
    for _, cell in ipairs(block_positions) do
        local tl, tr, bl, br = self:rectangle_coordinates(cell + (position_offset or vec2(0,0)), offset or self.offset, scale or self.scale)
        local w, h = (tl - br).x, (tl - br).y
        love.graphics.setColor((piece.shape.colour + Colour(0, 0, 0, 0.5 * (1 - piece.lock_delay_timer / piece.lock_delay))):toRGBA())
        love.graphics.rectangle("fill", tl.x, tl.y, w, h)
    end
end

function Renderer:drawShape(shape, position_offset, offset, scale)
    -- Draws a Shape to the screen.
    local block_positions = shape:getCurrentArrangement().block_list
    for _, cell in ipairs(block_positions) do
        local tl, tr, bl, br = self:rectangle_coordinates(cell + (position_offset or vec2(0,0)), offset or self.offset, scale or self.scale)
        local w, h = (tl - br).x, (tl - br).y
        love.graphics.setColor((shape.colour):toRGBA())
        love.graphics.rectangle("fill", tl.x, tl.y, w, h)
    end
end

function Renderer:drawBoard(board, offset, scale)
    -- Draws a Board to the screen. By default, draws the piece relative to the board at the internal scale and offset (can be overridden).
    
    for y = 1, board.height do
        local row_is_cleared = board.rows[y].cleared
        for x = 1, board.width do
            local position = vec2(x, y)
            local cell = board:getCell(position)
            local tl, tr, bl, br = self:rectangle_coordinates(position, offset or self.offset, scale or self.scale)
            local w, h = (tl - br).x, (tl - br).y

            local new_background_colour = board.background_colour
            if((x + y) % 2 == 0) then
                new_background_colour = new_background_colour + Colour(0,0,0,0.1)
            end
            if(y > board.hidden_rows) then
                love.graphics.setColor(new_background_colour:toRGBA())
                love.graphics.rectangle("fill", tl.x, tl.y, w, h)
            end
            if(cell) then
                if(row_is_cleared) then
                    love.graphics.setColor(1,1,1,1)
                else
                    love.graphics.setColor(cell.colour:toRGBA())
                end
                love.graphics.rectangle("fill", tl.x, tl.y, w, h)
            end
        end
    end
end

function Renderer:drawPieceQueue(queue, engine, start_position, delta_position)
    for i, piece in ipairs(queue) do
        renderer:drawShapeRelativeToBoard(piece, engine.board, start_position + delta_position * (i-1))
    end
end

function Renderer:drawStatistic(board, name, value, side, position)
    -- position is aligned to the bottom, not the top!

    local text_width = 300
    local top_left = vec2(board.width * self.scale * -0.5, (board.height + board.hidden_rows) * -0.5 * self.scale) + self.offset
    local alignment = (side == "left") and "right" or "left"
    local x_position = (side == "left") and (top_left.x - 10 - text_width) or (top_left.x + (board.width * self.scale) + 10)
    local y_position = top_left.y + (board.height * self.scale) - position - (fonts.sd16.baseSize * 5 + 14)
    fonts.sd16:setActive(2)
    love.graphics.printf(name, x_position, y_position, text_width, alignment)
    fonts.sd16m:setActive(3)
    love.graphics.printf(value, x_position, y_position + 14, text_width, alignment)
    
end

function Renderer:draw(object)
    -- Dispatches the respective draw function. Does not allow for customization.
    if(type(object) == "Piece") then self:drawPiece(object) end
    if(type(object) == "Board") then self:drawBoard(object) end
end

setmetatable(Renderer, {
    __call = Renderer.new
})

return Renderer
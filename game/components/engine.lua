Piece = require "game.components.piece"
Shapes = require "game.data.shapes"

local Engine = {
    mt = {
        __type = "Engine"
    }
}

function Engine:new(board, pieces, randomizer)
    local new_engine = {
        board = board,
        pieces = pieces,
        objects = {board, unpack(pieces)},
        randomizer = randomizer,

        lines = 0,
        score = 0,

        getAllObjects = self.getAllObjects,
        update_objects = self.update_objects,
        generate_new_piece = self.generate_new_piece,
        updateObjectList = self.updateObjectList,

        updateSpawnDelays = self.updateSpawnDelays,
        updateGravity = self.updateGravity,
        updateLockDelay = self.updateLockDelay,
        updateBoard = self.updateBoard,

        initialize = self.initialize
    }

    setmetatable(new_engine, Engine.mt)
    new_engine:initialize()

    return new_engine
end

function Engine:updateObjectList()
    self.objects = {self.board, unpack(self.pieces)}
end

function Engine:getAllObjects()
    return {self.board, unpack(self.pieces)}
end

function Engine:initialize()
    self.next_queue = {}
    for i=1,5 do
        table.insert(self.next_queue, self.randomizer:generatePiece())
    end
end

function Engine:generate_new_piece()
    table.insert(self.next_queue, self.randomizer:generatePiece())
    return table.remove(self.next_queue, 1)
end

-- These functions are, by default, called in this order.
-- You can change the behaviours by modifying these functions,
-- or the entire engine behaviour by modifying update_objects.

function Engine:updateSpawnDelays(dt)
    for _, piece in pairs(self.pieces) do
        if(not piece.shape) then
            piece.spawn_delay_timer = piece.spawn_delay_timer - dt
            if(piece.spawn_delay_timer <= 0) then
                piece.spawn_delay_timer = 0

                -- supposed to put / call a randomizer here but for now it's fine
                if(not piece.new_shape) then
                    piece.new_shape = self:generate_new_piece()
                end
                piece:respawn(copy(piece.new_shape))

                if(piece:collidesWithAny(self.pieces)) then
                    piece.shape = nil
                else
                    piece.new_shape = nil
                end
            end
        end
        if(piece.shape) then
            -- note: this isn't an else branch because this performs one tick of gravity immediately after the piece spawns
            -- update gravity while we're at it
            if(not piece:isGrounded(self.objects)) then
                piece.gravity_timer = piece.gravity_timer - dt
            end
        end
    end
end

function Engine:updateGravity(dt)
    local anyMovements = true
    while anyMovements do
        anyMovements = false
        for _, piece in pairs(self.pieces) do
            if(piece.gravity_timer <= 0 and piece.shape) then
                piece:resetGravity(true)
                local moved = piece:attemptMove(self.objects, vec2(0, 1))
                if(moved) then
                    anyMovements = true
                    piece.lock_delay_timer = piece.lock_delay
                else
                    piece.gravity_timer = 0
                end
            end
        end
    end
end

function Engine:updateLockDelay(dt)
    for _, piece in pairs(self.pieces) do
        if(piece.shape) then
            if(piece:isGrounded(self.objects)) then
                piece.lock_delay_timer = piece.lock_delay_timer - dt
            end
            if(piece.lock_delay_timer <= 0) then
                piece.lock_delay_timer = piece.lock_delay
                piece:place(self.board)
            end
        end
    end
end

function Engine:updateBoard(dt)
    if(#self.board.full_rows > 0) then
        local line_count = 0
        for _, row_index in ipairs(self.board.full_rows) do
            -- should probably put, like, line ARE or something here?
            self.board:removeRow(row_index)
            line_count = line_count + 1
        end
        
        self.lines = self.lines + line_count
        self.score = self.score + (50 * 2 ^ line_count) * self.lines

        self.board:checkFullRows()
    end

    return self
end

function Engine:update_objects(dt)
    -- ARE
    self:updateSpawnDelays(dt)

    -- gravity
    self:updateGravity(dt)

    -- lock delay
    self:updateLockDelay(dt)

    -- cleared rows
    local test_self = self:updateBoard(dt)
    assert(self == test_self)

    -- long ago, the four nations lived in harmony
end

setmetatable(Engine, {
    __call = Engine.new
})

return Engine
-- A controllable piece, made up of a Shape and a position.

local Shape = require "game.components.shape"
local vec2 = require "game.components.vec2"

local Piece = {
    mt = {
        __type = "Piece"
    }
}

-- Returns a new Piece.
function Piece:new(shape, spawn_position, position, extras)
    local extras = extras or {}
    local new_piece = {
        shape = shape,
        position = vec2(0,0),

        held = false,
        spawn_position = spawn_position or vec2(0,0),

        -- Pieces, by default, keep an internal timer to assist in spawn delay timing. The piece must still be respawned manually, though.
        spawn_delay_timer = extras.spawn_delay_timer or 0,
        spawn_delay = extras.spawn_delay or 0,

        -- Along with an internal gravity timer.
        gravity = extras.gravity or 0, -- in hz, not G
        gravity_timer = extras.gravity_timer or 0,

        -- And a lock delay timer.
        lock_delay = extras.lock_delay or math.huge, -- in hz, not G
        lock_delay_timer = extras.lock_delay_timer or 0,

        getBlockPositions = self.getBlockPositions,
        resetGravity = self.resetGravity,

        collidesWith = self.collidesWith,
        collidesWithOffset = self.collidesWithOffset,
        collidesWithRotation = self.collidesWithRotation,
        collidesWithAny = self.collidesWithAny,

        attemptMove = self.attemptMove,
        attemptRotate = self.attemptRotate,
        attemptRotateWithKicks = self.attemptRotateWithKicks,

        place = self.place,
        isGrounded = self.isGrounded,
        respawn = self.respawn,
        move = self.move,
        rotate = self.rotate,
        hold = self.hold
    }
    new_piece:respawn(shape, position)
    setmetatable(new_piece, self.mt)
    return new_piece
end

-- Respawns a Piece with a specified shape, optionally at a specified position.
function Piece:respawn(shape, position)
    self.shape = copy(shape)
    self.position = position or self.spawn_position

    -- premovements
    if(self.input_handler) then
        for name, callback in pairs(self.input_handler.callbacks) do
            if(self.input_handler.is_down[name] and self.input_handler.repeat_delays[name]) then
                if(self.input_handler.repeat_delays[name].premove_remaining) then
                    -- can't really think of a good way to do this? though if you're not passing self to this you're probably doing something wrong
                    callback(self, unpack(self.input_handler.callback_parameters))
                    if(self.input_handler.repeat_delays[name].single_premove) then
                        self.input_handler.repeat_delays[name].premove_remaining = false
                    end
                end
                if(self.input_handler.repeat_delays.precharge) then
                    self.input_handler:charge(name)
                end
            end
        end
    end
end

-- Returns the global position of the Piece's Shape's blocks, including the Piece's position.
function Piece:getBlockPositions()
    if(not self.shape) then return {} end
    local blocks = {}
    for _, block in ipairs(self.shape:getCurrentArrangement().block_list) do
        table.insert(blocks, block + self.position)
    end
    return blocks
end

-- Returns true if the Piece collides with the specified object (either a Board or another Piece).
function Piece:collidesWith(obj)
    if(not self.shape) then return false end

    if(self == obj) then
        -- No, you can't collide with yourself, sorry
        return false
    elseif(type(obj) == "Piece") then
        -- Piece-piece collision.
        local my_positions = self:getBlockPositions()
        local other_positions = obj:getBlockPositions()

        for _, my_cell in ipairs(my_positions) do
            for _, other_cell in ipairs(other_positions) do
                if(my_cell == other_cell) then
                    return true
                end
            end
        end

        return false
    elseif(type(obj) == "Board") then
        -- Piece-board collision.
        local my_positions = self:getBlockPositions()

        for _, cell_pos in ipairs(my_positions) do
            if(obj:getCell(cell_pos)) then
                return true
            end
        end

        return false
    end
end

-- Attempts to swap the Piece's shape with an Engine's reserve shape; can only be done once per placement..
function Piece:hold(engine)
    -- extremely subject to change, very temporary!
    if(not self.held and self.shape) then
        self.held = true
        if(not engine.reserve_shape) then
            engine.reserve_shape = engine:generate_new_piece()
        end
        
        self.shape.current_rotation = self.shape.initial_rotation
        local reserve_copy = copy(engine.reserve_shape)
        engine.reserve_shape = self.shape
        self:respawn(reserve_copy)
    end
end

-- Places a Piece onto a Board.
function Piece:place(board)
    if(not self.shape) then return {} end
    local blocks = {}
    for _, block in ipairs(self.shape:getCurrentArrangement().block_list) do
        board:setCell(block + self.position, Cell(true, self.shape.colour, 0))
    end

    self.shape = nil
    self.held = false
    self.spawn_delay_timer = self.spawn_delay
    self:resetGravity()
    self.lock_delay_timer = self.lock_delay

    board:checkFullRows()
end

-- Rotates a Piece's shape, if it has one.
function Piece:rotate(rotations)
    if(not self.shape) then return false end
    self.shape:rotate(rotations)
end

-- Moves a Piece, regardless of whether it ends up colliding with anything.
function Piece:move(offset)
    if(not self.shape) then return false end
    self.position = self.position + offset
end

-- Given a list of objects, returns true if the piece is currently on the ground of a Board; false otherwise.
function Piece:isGrounded(objects)
    -- This ONLY counts piece-to-ground collisions--not piece-to-piece collisions.
    for _, obj in pairs(objects) do
        if(type(obj) == "Board") then
            if(self:collidesWithOffset(obj, vec2(0, 1))) then
                return true
            end
        end
    end
    return false
end

-- Resets the gravity timer of a Piece, optionally accumulating it instead of setting it.
function Piece:resetGravity(accumulate, sdf)
    -- Only for soft drops.
    if(self.soft_dropping) then
        accumulated_gravity = (1 / (sdf or 3)) / self.gravity
    else
        accumulated_gravity = 1 / self.gravity
    end

    if(accumulate) then
        self.gravity_timer = self.gravity_timer + accumulated_gravity
    else
        self.gravity_timer = accumulated_gravity
    end
end

-- Given an object, attempts to move the Piece, cancelling the movement if it collides with the object.
function Piece:collidesWithOffset(obj, offset)
    if(not self.shape) then return false end
    self:move(offset)
    local collides = self:collidesWith(obj)
    self:move(vec2(0,0) - offset)
    return collides
end

-- Given an object, attempts to rotate the Piece, cancelling the rotation if it collides with the object.
function Piece:collidesWithRotation(obj, rotations)
    if(not self.shape) then return false end
    self:rotate(rotations)
    local collides = self:collidesWith(obj)
    self:rotate(-rotations)
    return collides
end

-- Returns true if the Piece collides with any of the objects in the provided list, false otherwise.
function Piece:collidesWithAny(collision_list)
    if(not self.shape) then return false end
    for _, obj in ipairs(collision_list) do
        if(self:collidesWith(obj)) then
            return true
        end
    end
    return false
end

-- Similar to collidesWithOffset, but for a list of objects.
function Piece:attemptMove(collision_list, offset)
    if(not self.shape) then return false end
    for _, obj in ipairs(collision_list) do
        if(self:collidesWithOffset(obj, offset)) then
            return false
        end
    end
    self:move(offset)
    return true
end

-- Similar to collidesWithRotation, but for a list of objects.
function Piece:attemptRotate(collision_list, rotations)
    if(not self.shape) then return false end
    for _, obj in ipairs(collision_list) do
        if(self:collidesWithRotation(obj, rotations)) then
            return false
        end
    end
    self:rotate(rotations)
    return true
end

-- Similar to attemptRotate, but tries kicks if the rotation fails initially.
function Piece:attemptRotateWithKicks(collision_list, rotations, kick_generator)
    if(not self.shape) then return false end
    if(self:attemptRotate(collision_list, rotations)) then return true end
    if(not kick_generator) then return false end
    local original_position = vec2(self.position)
    local kick_list = kick_generator:getKickSet(self)
    while (kick_list:getNextKick()) do
        self.position = original_position + kick_list:getCurrentKick()
        if(self:attemptRotate(collision_list, rotations)) then return true end
    end
    self.position = original_position
    return false
end


setmetatable(Piece, {
    __call = Piece.new
})

return Piece
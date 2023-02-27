-- Wrapper for a "shape", a list of arrangements that can be "rotated".

vec2 = require "game.components.vec2"
Colour = require "game.components.colour"

Shape = {}

-- Returns a new Shape.
function Shape:new(arrangements, colour, rotation_center, current_rotation)
    newShape = {
        arrangements = arrangements,
        colour = colour or Colour(1, 1, 1),
        current_rotation = current_rotation or 0,
        initial_rotation = current_rotation or 0,
        arrangement_count = #arrangements,
        rotation_center = rotation_center or vec2(0, 0),

        getCurrentArrangement = Shape.getCurrentArrangement,
        rotate = Shape.rotate
    }
    setmetatable(newShape, self.mt)
    return newShape
end

-- Returns the Shape's current Arrangement.
function Shape:getCurrentArrangement()
    return self.arrangements[self.current_rotation + 1]
end

-- Rotates the Shape.
function Shape:rotate(rotations)
    self.current_rotation = (self.current_rotation + rotations) % self.arrangement_count
    return self
end

Shape.mt = {
    __type = "Shape",
    
    __add = Shape.rotate,
    __sub = function(self, number)
        return Shape.rotate(self, -number)
    end
}

setmetatable(Shape, {
    __call = Shape.new
})

return Shape
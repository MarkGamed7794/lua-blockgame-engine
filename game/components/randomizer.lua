-- An object responsible for returning Shapes in a randomized, programmable way.

local Randomizer = {
    mt = {
        __type = "Randomizer"
    }
}

function Randomizer:new(shapes)
    -- The default randomizer just picks from the pool at random.
    -- Note: returns the piece NAME, not the piece itself!
    local new_randomizer = {
        shapes = shapes,
        generatePiece = self.generatePiece
    }

    setmetatable(new_randomizer, self.mt)

    return new_randomizer
end

function Randomizer:generatePiece()
    return self.shapes[math.floor(math.random() * #self.shapes) + 1]
end

setmetatable(Randomizer, {
    __call = Randomizer.new
})

return Randomizer
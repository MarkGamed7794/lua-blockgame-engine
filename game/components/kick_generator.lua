-- Kick generator, which returns a KickSet to try on the piece whenever it needs one.

local vec2 = require "game.components.vec2"

local KickGenerator = {}

-- Returns a new KickGenerator.
function KickGenerator:new(callback)
    -- The callback should take itself and a Piece as input and return a KickSet.
    newKickGenerator = {
        callback = callback,
        getKickSet = self.getKickSet
    }
    setmetatable(newKickGenerator, self.mt)
    return newKickGenerator
end

function KickGenerator:getKickSet(piece)
    return self:callback(piece)
end

KickGenerator.mt = {
    __type = "KickGenerator"
}

setmetatable(KickGenerator, {
    __call = KickGenerator.new
})

return KickGenerator
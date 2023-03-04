-- Literally just a list of kicks. Intended to self-destruct.

local vec2 = require "game.components.vec2"

local KickSet = {}

-- Returns a new KickSet.
function KickSet:new(list)
    -- list should just be a list of vec2s.
    newKickSet = {
        kick_list = list,
        getNextKick = self.getNextKick,
        getCurrentKick = self.getCurrentKick,
        current_kick = 0,
    }
    setmetatable(newKickSet, self.mt)
    return newKickSet
end

function KickSet:getNextKick(piece)
    self.current_kick = self.current_kick + 1
    return self.kick_list[self.current_kick]
end

function KickSet:getCurrentKick(piece)
    return self.kick_list[self.current_kick]
end

KickSet.mt = {
    __type = "KickSet"
}

setmetatable(KickSet, {
    __call = KickSet.new
})

return KickSet
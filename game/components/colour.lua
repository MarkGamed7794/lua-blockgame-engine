-- Easy interface for adding RGBA colours.

local Colour = {}

-- Returns a new Colour. Yes, it's spelt with a U--deal with it.
function Colour:new(r, g, b, a)
    local c = {r=r, g=g, b=b, a=a or 1, toRGBA=Colour.toRGBA}
    setmetatable(c,Colour.mt)
    return c
end

-- Returns the Colour result of overlaying the fg Colour on top of the bg Colour.
function Colour.add(bg, fg)
    local newAlpha = 1 - (1 - fg.a) * (1 - bg.a)
    if(newAlpha == 0) then return Colour(0,0,0,0) end
    return Colour(
        fg.r * fg.a / newAlpha + bg.r * bg.a * (1 - fg.a) / newAlpha,
        fg.g * fg.a / newAlpha + bg.g * bg.a * (1 - fg.a) / newAlpha,
        fg.b * fg.a / newAlpha + bg.b * bg.a * (1 - fg.a) / newAlpha,
        newAlpha
    )
end

-- Returns a Colour whose alpha is multiplied by a number.
function Colour.mult(col, n)
    -- Not true colour multiplication; it just mulitplies the alpha
    -- so a + (b * 0.5) averages the colours

    return Colour(
        col.r, col.g, col.b, col.a * n
    )
end

-- Returns the R, G, B, and A values of a Colour.
function Colour:toRGBA()
    return self.r,self.g,self.b,self.a
end

Colour.mt = {
    __add = Colour.add,
    __mul = Colour.mult
}

setmetatable(Colour, {
    __call = Colour.new
})

return Colour
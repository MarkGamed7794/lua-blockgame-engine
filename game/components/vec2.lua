-- 2D vector type.

Vec2 = {
    mt = {
        __type = "vec2",

        __add = function(a, b)
            return Vec2:new(a.x + b.x, a.y + b.y)
        end,
        __sub = function(a, b)
            return Vec2:new(a.x - b.x, a.y - b.y)
        end,

        __mul = function(a, b)
            if(type(a) == "number") then
                return Vec2:new(a * b.x, a * b.y)
            end
            if(type(b) == "number") then
                return Vec2:new(b * a.x, b * a.y)
            end

            -- dot product
            return Vec2:new(a.x * b.x, a.y * b.y)
        end,

        __div = function(a, b)
            if(type(b) == "number") then
                return Vec2:new(a.x / b, a.y / b)
            end

            -- dot.. quotient??
            return Vec2:new(a.x / b.x, a.y / b.y)
        end,
        
        __tostring = function(a)
            return "("..a.x..", "..a.y..")"
        end,

        __neg = function(a)
            return Vec2:new(-a.x, -a.y)
        end,

        __eq = function(a, b)
            return (a.x == b.x and a.y == b.y)
        end,

        -- I don't know why but sometimes using this causes an access violation in Love2D. Just don't use it?
        __concat = function(a, b) 
            return tostring(a) .. tostring(b)
        end
    }
}

function Vec2:new(x, y)
    local new_x, new_y = x, y
    if(type(x) == "vec2") then new_x, new_y = x.x, x.y end
    local vec = {x=new_x or 0, y=new_y or 0}
    setmetatable(vec, Vec2.mt)
    return vec
end

setmetatable(Vec2,{
    __call = Vec2.new
})

return Vec2
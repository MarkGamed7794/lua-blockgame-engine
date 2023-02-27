fonts = {}

function fonts:newFont(filename, alias, baseSize)
    self[alias] = {
        filename=filename,
        baseSize=baseSize,
        sizes={},
        setActive=function(self, size)
            local scaledSize = size * self.baseSize
            if(not self.sizes[size]) then
                print("Making new font")
                local font = love.graphics.newFont(self.filename, scaledSize)
                font:setFilter("nearest")
                self.sizes[size] = font
                
            end
            love.graphics.setFont(self.sizes[size])
        end
    }
end

return fonts
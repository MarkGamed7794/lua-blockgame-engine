-- An arrangement of Blocks.

local Arrangement = {}

-- Returns a new Arrangement.
function Arrangement:new(block_list)
    new_arrangement = {
        block_list = block_list
    }
    setmetatable(new_arrangement, self.mt)
    return new_arrangement
end

setmetatable(Arrangement, {
    __call = Arrangement.new
})

return Arrangement
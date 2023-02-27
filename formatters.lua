formatters = {
    number = function(number)
        -- https://stackoverflow.com/questions/10989788/format-integer-in-lua
        local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
        int = int:reverse():gsub("(%d%d%d)", "%1,")
        return minus .. int:reverse():gsub("^,", "") .. fraction
    end,
    time = function(seconds)
        return string.format("%02d:%02d.%03d", seconds / 60, seconds % 60, (seconds % 1) * 1000)
    end
}

return formatters
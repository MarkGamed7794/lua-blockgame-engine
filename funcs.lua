raw_type = type
-- modified type function; allows metatable "__type" key
function type(o)
    local mt = getmetatable(o)
    if mt and mt.__type then
        return tostring(mt.__type)
    else
        return raw_type(o)
    end
end

-- from the lua-users wiki
function copy(orig)
    local orig_type = raw_type(orig)
    local c
    if orig_type == 'table' then
        c = {}
        for orig_key, orig_value in next, orig, nil do
            c[copy(orig_key)] = copy(orig_value)
        end
        setmetatable(c, copy(getmetatable(orig)))
    else
        c = orig
    end
    return c
end

function table.map(t, f)
    -- behaves like the javascript Array.map()
    local new_t = {}
    for k, v in pairs(t) do
        new_t[k] = f(v)
    end
    return new_t
end
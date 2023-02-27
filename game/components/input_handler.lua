-- Interface for hooking up inputs to functions.

local InputHandler = {
    mt = {
        __type = "InputHandler",
    }
}

-- Returns a new InputHandler.
function InputHandler:new(keybinds, callbacks, release_callbacks, callback_parameters, repeat_delays)
    new_input_handler = {
        keybinds = keybinds,
        repeat_delays = repeat_delays or {},
        is_down = {},
        callbacks = callbacks or {},
        release_callbacks = release_callbacks or {},
        key_timers = {},
        callback_parameters = callback_parameters,

        update = self.update,
        keypressed = self.keypressed,
        keyreleased = self.keyreleased,
        charge = self.charge
    }
    setmetatable(new_input_handler, self.mt)
    return new_input_handler
end

-- Updates the timers for held keys.
function InputHandler:update(dt, arguments)
    -- This doesn't check any of the keys; that responsibility is given to the InputHandler keypressed/keyreleased functions.
    for name, _ in pairs(self.callbacks) do
        if(self.is_down[name]) then
            self.key_timers[name] = self.key_timers[name] + dt
            if(self.repeat_delays[name]) then
                if(self.repeat_delays[name].delay) then
                    if(self.key_timers[name] >= self.repeat_delays[name].delay) then
                        self.key_timers[name] = self.key_timers[name] - self.repeat_delays[name].period
                        self.callbacks[name](unpack(arguments or self.callback_parameters))
                    end
                end
            end
        end
    end
end

-- Immediately sets an autorepeating bind's timer so it will start repeating after the time it takes for said input to repeat.
function InputHandler:charge(name)
    if(not self.repeat_delays[name]) then error("Attempt to charge input \"" .. name .. "\", which has no delay parameters") end
    self.key_timers[name] = self.repeat_delays[name].delay - self.repeat_delays[name].period
end

-- Intended to be hooked up to the love2d keypressed function. See the love2d reference for details.
function InputHandler:keypressed(key, scancode, isrepeat, arguments)
    -- Arguments is a table passed on as function arguments to the callback.
    if(self.keybinds[scancode]) then
        local name = self.keybinds[scancode]
        self.is_down[name] = true
        self.key_timers[name] = 0
        self.callbacks[name](unpack(arguments))
        if(self.repeat_delays[name]) then
            if(self.repeat_delays[name].premove) then
                self.repeat_delays[name].premove_remaining = true
            end
        end
    end
end

-- Intended to be hooked up to the love2d keyreleased function. See the love2d reference for details.
function InputHandler:keyreleased(key, scancode, arguments)
    if(self.keybinds[scancode]) then
        local name = self.keybinds[scancode]
        self.is_down[name] = false
        if(self.release_callbacks[name]) then
            self.release_callbacks[name](unpack(arguments or self.callback_parameters))
        end
    end
end

setmetatable(InputHandler, {
    __call = InputHandler.new
})

return InputHandler
math.randomseed(os.clock())

require "funcs"

fonts, shaders = unpack(require "assets")
formatters = require "formatters"
Engine = require "game.engine"
colours = require "game.data.colours"
Board = require "game.components.board"
Arrangement = require "game.components.arrangement"
Block = require "game.components.block"
Cell = require "game.components.cell"
Piece = require "game.components.piece"
Shape = require "game.components.shape"
Renderer = require "game.components.renderer"
Shapes = require "game.data.shapes"
InputHandler = require "game.components.input_handler"
Randomizer = require "game.components.randomizer"
vec2 = require "game.components.vec2"

local t = 0

engine = Engine(Board(10, 20, 10, Colour(0.2,0.2,0.2)), {
    Piece(nil, vec2(5, 10), vec2(2, 10), {spawn_delay = 0.2, gravity = 8, lock_delay = 1}),
}, Randomizer(table.map({"Z", "L", "O", "S", "I", "J", "T"}, function(name) return Shapes[name] end)))

engine:updateObjectList()

renderer = Renderer(engine, vec2(400, 300), 18)

local piece_pressed_functions = {
    left=function(piece, engine)
        piece:attemptMove(engine.objects, vec2(-1, 0))
    end,
    right=function(piece, engine)
        piece:attemptMove(engine.objects, vec2(1, 0))
    end,
    down=function(piece, engine)
        piece.soft_dropping = true
        piece:attemptMove(engine.objects, vec2(0, 1))
        piece:resetGravity()
    end,
    up=function(piece, engine)
        while(piece:attemptMove(engine.objects, vec2(0, 1))) do
            engine.score = engine.score + 2
        end

        if(piece:isGrounded(engine.objects)) then
            piece:place(engine.board)
        end
    end,
    ccw=function(piece, engine)
        piece:attemptRotate(engine.objects, -1)
    end,
    cw=function(piece, engine)
        piece:attemptRotate(engine.objects, 1)
    end,
    hold=function(piece, engine)
        piece:hold(engine)
    end
}

local piece_released_functions = {
    down=function(piece, engine)
        piece.soft_dropping = false
    end
}

for i=1,#engine.pieces do
    engine.pieces[i].input_handler = InputHandler(
        {left="left", right="right", z="ccw", x="cw", down="down", up="up", lshift="hold"},
        piece_pressed_functions,
        piece_released_functions,
        {engine},
        {
            left={delay = 10/60, period = 2/60, precharge = true},
            right={delay = 10/60, period = 2/60, precharge = true},
            ccw={premove = true, single_premove = true},
            cw={premove = true, single_premove = true},
            hold={premove = true, single_premove = true},
        }
    )
end


function love.update(dt)
    t = t + dt
    engine:update_objects(dt)

    for _, piece in pairs(engine.pieces) do
        if(piece.input_handler) then
            piece.input_handler:update(dt, {piece, engine})
        end
    end
end

function love.draw()
    fonts.sd16:setActive(2)
    
    local status, charging, time = love.system.getPowerInfo()
    love.graphics.setColor(1,1,1,1)
    
    love.graphics.printf(tostring(love.timer.getFPS()).."fps", 4, 4, 400, "left")
     
    renderer:drawEngine(engine)
    renderer:drawPieceQueue(engine.next_queue, engine, vec2(engine.board.width + 3, 12), vec2(0, 3))
    renderer:drawPieceQueue({engine.reserve_shape}, engine, vec2(-3, 12), vec2(0, 3))
    
    love.graphics.setColor(1,1,1,1)
    renderer:drawStatistic(engine.board, "Lines", engine.lines, "right", 0)
    renderer:drawStatistic(engine.board, "Score", formatters.number(engine.score), "left", 0)
    renderer:drawStatistic(engine.board, "Time", formatters.time(t), "left", 45)
    renderer:drawStatistic(
        engine.board,
        string.format("Gravity (%.3f Hz)", engine.pieces[1].gravity),
        string.format("%.3f/%.3f", engine.pieces[1].gravity_timer, 1 / engine.pieces[1].gravity),
        "left",
        90
    )
    renderer:drawStatistic(engine.board, "Lock Delay", string.format("%.3f/%.3f", engine.pieces[1].lock_delay_timer, engine.pieces[1].lock_delay), "left", 135)
    renderer:drawStatistic(engine.board, "Spawn Delay", string.format("%.3f/%.3f", engine.pieces[1].spawn_delay_timer, engine.pieces[1].spawn_delay), "left", 180)
end

function love.keypressed(k, s, r)
    for _, piece in pairs(engine.pieces) do
        if(piece.input_handler) then
            piece.input_handler:keypressed(k, s, r, {piece, engine})
        end
    end
end

function love.keyreleased(k, s)
    for _, piece in pairs(engine.pieces) do
        if(piece.input_handler) then
            piece.input_handler:keyreleased(k, s, {piece, engine})
        end
    end
end
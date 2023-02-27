-- Easy access for Shapes.

Shape = require "game.components.shape"
Arrangement = require "game.components.arrangement"
Colours = require "game.data.colours"

Shapes = {
    T = Shape(
        {
            Arrangement({vec2( 0,-1), vec2(-1, 0), vec2( 0, 0), vec2( 1, 0)}),
            Arrangement({vec2( 0,-1), vec2( 0, 0), vec2( 1, 0), vec2( 0, 1)}),
            Arrangement({vec2(-1, 0), vec2( 0, 0), vec2( 1, 0), vec2( 0, 1)}),
            Arrangement({vec2( 0,-1), vec2(-1, 0), vec2( 0, 0), vec2( 0, 1)})
        },
        Colours.purple
    ),

    O = Shape(
        {
            Arrangement({vec2( 0,-1), vec2( 1,-1), vec2( 0, 0), vec2( 1, 0)}),
            Arrangement({vec2( 0,-1), vec2( 1,-1), vec2( 0, 0), vec2( 1, 0)}),
            Arrangement({vec2( 0,-1), vec2( 1,-1), vec2( 0, 0), vec2( 1, 0)}),
            Arrangement({vec2( 0,-1), vec2( 1,-1), vec2( 0, 0), vec2( 1, 0)})
        },
        Colours.yellow
    ),

    I = Shape(
        {
            Arrangement({vec2(-1, 0), vec2( 0, 0), vec2( 1, 0), vec2( 2, 0)}),
            Arrangement({vec2( 1,-1), vec2( 1, 0), vec2( 1, 1), vec2( 1, 2)}),
            Arrangement({vec2(-1, 1), vec2( 0, 1), vec2( 1, 1), vec2( 2, 1)}),
            Arrangement({vec2( 0,-1), vec2( 0, 0), vec2( 0, 1), vec2( 0, 2)})
        },
        Colours.cyan
    ),

    Z = Shape(
        {
            Arrangement({vec2(-1,-1), vec2( 0,-1), vec2( 0, 0), vec2( 1, 0)}),
            Arrangement({vec2( 1,-1), vec2( 0, 0), vec2( 1, 0), vec2( 0, 1)}),
            Arrangement({vec2(-1, 0), vec2( 0, 0), vec2( 0, 1), vec2( 1, 1)}),
            Arrangement({vec2( 0,-1), vec2(-1, 0), vec2( 0, 0), vec2(-1, 1)})
        },
        Colours.red
    ),

    S = Shape(
        {
            Arrangement({vec2( 0,-1), vec2( 1,-1), vec2(-1, 0), vec2( 0, 0)}),
            Arrangement({vec2( 0,-1), vec2( 0, 0), vec2( 1, 0), vec2( 1, 1)}),
            Arrangement({vec2( 0, 0), vec2( 1, 0), vec2(-1, 1), vec2( 0, 1)}),
            Arrangement({vec2(-1,-1), vec2(-1, 0), vec2( 0, 0), vec2( 0, 1)})
        },
        Colours.green
    ),

    J = Shape(
        {
            Arrangement({vec2(-1,-1), vec2(-1, 0), vec2( 0, 0), vec2( 1, 0)}),
            Arrangement({vec2( 0,-1), vec2( 1,-1), vec2( 0, 0), vec2( 0, 1)}),
            Arrangement({vec2(-1, 0), vec2( 0, 0), vec2( 1, 0), vec2( 1, 1)}),
            Arrangement({vec2( 0,-1), vec2( 0, 0), vec2(-1, 1), vec2( 0, 1)})
        },
        Colours.blue
    ),

    L = Shape(
        {
            Arrangement({vec2( 1,-1), vec2(-1, 0), vec2( 0, 0), vec2( 1, 0)}),
            Arrangement({vec2( 0,-1), vec2( 0, 0), vec2( 0, 1), vec2( 1, 1)}),
            Arrangement({vec2(-1, 0), vec2( 0, 0), vec2( 1, 0), vec2(-1, 1)}),
            Arrangement({vec2(-1,-1), vec2( 0,-1), vec2( 0, 0), vec2( 0, 1)})
        },
        Colours.orange
    ),

}

return Shapes
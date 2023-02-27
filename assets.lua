fonts = require "assets.fonts"
shaders = require "assets.shaders"

-- Defines all assets, then re-returns them.

fonts:newFont("assets/fonts/spiritdrop16.ttf", "sd16", 7)
fonts:newFont("assets/fonts/spiritmono16.ttf", "sd16m", 7)


return {fonts,shaders}
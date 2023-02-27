extern float factor;
extern vec2 gridOffset;

vec4 effect(vec4 color, Image img, vec2 texture_coords, vec2 pixel_coords){
    vec2 screenSize = love_ScreenSize.xy;
    vec2 imgPos = (floor((texture_coords * screenSize + gridOffset) / factor) * factor - gridOffset) / screenSize;
    return color * Texel(img, imgPos);
}
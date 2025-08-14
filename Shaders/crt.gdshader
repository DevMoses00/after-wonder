shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture;

uniform float pixel_size = 2.0;
uniform float curvature = 0.1;
uniform float vignette_intensity = 0.4;
uniform float scanline_intensity = 0.2;
uniform float glitch_intensity = 0.02;  // amount of glitch distortion
uniform float chroma_offset = 0.0015;   // RGB separation

void fragment() {
    vec2 uv = SCREEN_UV;

    // CRT Curvature
    vec2 center = uv - 0.5;
    float dist = dot(center, center) * curvature;
    uv += center * dist;
    uv = clamp(uv, vec2(0.0), vec2(1.0));

    // Resolution for pixel effects
    vec2 res = vec2(textureSize(screen_tex, 0));

    // Pixelation
    uv = floor(uv * res / pixel_size) * pixel_size / res;
    uv = clamp(uv, vec2(0.0), vec2(1.0));

    // Dynamic Glitching (horizontal UV shift)
    float glitch = step(0.98, fract(sin(TIME * 13.0) * 43758.5453)); // random pulses
    uv.x += glitch * (fract(sin(uv.y * 500.0 + TIME * 20.0)) - 0.5) * glitch_intensity;

    // Chromatic Aberration (RGB channel offset)
    vec4 col;
    col.r = texture(screen_tex, uv + vec2(chroma_offset, 0.0)).r;
    col.g = texture(screen_tex, uv).g;
    col.b = texture(screen_tex, uv - vec2(chroma_offset, 0.0)).b;
    col.a = 1.0;

    // Scanlines
    float scan = sin(uv.y * res.y * 0.5) * scanline_intensity;
    col.rgb -= scan;

    // Pixel Grid
    vec2 pixel = uv * res / pixel_size;
    vec2 grid = fract(pixel);
    float grid_line = step(0.95, max(grid.x, grid.y));
    col.rgb *= 1.0 - grid_line * 0.4;

    // Vignette
    float vignette = smoothstep(0.8, 0.2, length(center) * 2.0);
    col.rgb *= mix(1.0, vignette, vignette_intensity);

    // Flicker (subtle brightness oscillation)
    col.rgb *= 1.0 + sin(TIME * 120.0) * 0.02;

    COLOR = col;
}

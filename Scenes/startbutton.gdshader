shader_type canvas_item;
uniform float time;

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    float pulse = 0.5 + sin(time * 5.0) * 0.5;
    col.rgb += pulse * 0.3; // brighten edges
    COLOR = col;
}

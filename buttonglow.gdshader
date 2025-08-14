shader_type canvas_item;

uniform float pulse_strength = 1.0;
uniform float time;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float pulse = 0.5 + sin(time * 5.0) * 0.5;
    float glow = smoothstep(0.2, 1.0, tex.a) * pulse_strength * pulse;
    COLOR = tex + vec4(glow, glow, glow, 0.0);
}



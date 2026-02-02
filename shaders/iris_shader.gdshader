shader_type canvas_item;

uniform vec2 center = vec2(0.5, 0.5);
uniform float radius = 0.5;   
uniform float feather = 0.0;  

void fragment() {
    vec2 uv = SCREEN_UV;

    vec2 p = uv - center;

    float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
    p.x *= aspect;

    float d = length(p);

    float a;
    if (feather <= 0.0) {
        a = step(radius, d);
    } else {
        a = smoothstep(radius, radius + feather, d);
    }

    COLOR = vec4(0.0, 0.0, 0.0, a);
}

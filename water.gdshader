shader_type spatial;

uniform vec4 primary_color : source_color = vec4(0.5,0.2,0.7,0.6);
uniform float roughness = 0.2;

uniform vec4 ice_color : source_color = vec4(0.8,0.9,1.0,1.0);
uniform float ice_roughness = 0.65;

uniform sampler2D normalmap_a : hint_normal;
uniform sampler2D normalmap_b : hint_normal;
uniform float normalmap_a_strength = 0.3;
uniform float normalmap_b_strength = 0.4;

uniform vec2 movement_direction = vec2(0.1, 0.1);
uniform float movement_strength = 0.35;
uniform float uv_scale = 1.0;

uniform float freeze : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    float t = clamp(freeze, 0.0, 1.0);

    //ease
    float motion_mul = 4.0 - smoothstep(0.0, 0.8, t);

    vec2 uv = UV * uv_scale;
    vec2 uv_movement = movement_direction * TIME * movement_strength * motion_mul;

    //fade
    float a_str = mix(normalmap_a_strength, 0.0, t);
    float b_str = mix(normalmap_b_strength, 0.05, t);

    vec3 n = texture(normalmap_a, uv + uv_movement).rgb * a_str;
    n += texture(normalmap_b, uv).rgb * b_str;

    vec3 albedo = mix(primary_color.rgb, ice_color.rgb, t);
    float alpha_out = mix(primary_color.a, 1.0, t);
    float rough = mix(roughness, ice_roughness, t);

    ALBEDO = albedo;
    ALPHA = alpha_out;
    ROUGHNESS = rough;
    NORMAL_MAP = n;
}

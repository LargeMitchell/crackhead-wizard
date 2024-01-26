shader_type sky;

uniform vec3 sky_color : source_color = vec3(0.2, 0.6, 1.0);
uniform vec3 horizon_color : source_color = vec3(0.2, 0.6, 1.0);
uniform sampler2D sky_noise;


void sky() {
	
	float cloud_thresh = abs(sin(TIME) * 0.4);
	
	float gradient_uv = max(1.0 - (SCREEN_UV.y + 0.3), 0.0);
	
	vec3 col = mix(horizon_color, sky_color, gradient_uv);
	
	vec4 noise_tex = texture(sky_noise, SCREEN_UV + TIME * 0.1);
	float noise_alpha = step(noise_tex.r, cloud_thresh);
	

	
	col = mix(col, vec3(1.0,1.0,1.0), noise_alpha);
	
	
	
	COLOR = col;
}
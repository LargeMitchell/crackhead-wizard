shader_type sky;

uniform sampler2D sky_noise;

void sky() {
	
	float cloud_thresh = abs(sin(TIME) * 0.4);
	
	vec4 noise_tex = texture(sky_noise, SCREEN_UV + TIME * 0.1);
	float noise_alpha = step(noise_tex.r, cloud_thresh);
	
	vec3 col = 0.5 + 0.5*cos(TIME + SCREEN_UV.xyx + vec3(0,2,4));
	vec3 col2 = 0.5 + 0.5*cos(TIME + (2.0 - SCREEN_UV.xyx) + vec3(0,2,4));
	
	col = mix(col, col2, noise_alpha);
	
	COLOR = col;
}

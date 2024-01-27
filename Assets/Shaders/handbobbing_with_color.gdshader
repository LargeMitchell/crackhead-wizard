shader_type canvas_item;

uniform float threshhold;

void vertex() {
	VERTEX.x = VERTEX.x + sin(TIME * 2.0) * 6.0;
	VERTEX.y = VERTEX.y + sin(TIME * 4.0) * 4.0;
}

void fragment(){
	vec4 texcol = texture(TEXTURE, UV);
	
	COLOR = texcol;
	COLOR.xyz = texcol.xyz * step(1.0 - UV.y, threshhold) * 0.5 + 0.5;
	
}
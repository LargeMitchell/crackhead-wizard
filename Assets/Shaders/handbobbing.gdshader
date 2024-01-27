shader_type canvas_item;

void vertex() {
	VERTEX.x = VERTEX.x + sin(TIME * 2.0) * 6.0;
	VERTEX.y = VERTEX.y + sin(TIME * 4.0) * 4.0;
}


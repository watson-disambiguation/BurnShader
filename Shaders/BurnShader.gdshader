shader_type canvas_item;

void fragment() {
	vec2 centeredUV = UV - 0.5;
	float distFromCenter = length(centeredUV);
	float distFromEdge = max((abs(centeredUV.x)),abs(centeredUV.y));
	float t = (sin(TIME) + 1.) * 0.25;
	float dist = mix(distFromCenter,distFromEdge,distFromCenter);
	float stepped = step(t,dist);
	COLOR = vec4(vec3(stepped),1);
}

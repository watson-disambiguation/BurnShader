shader_type canvas_item;

uniform sampler2D noiseTexture : source_color;

void fragment() {
	float noise = texture(noiseTexture,UV).x * 0.05;
	vec2 centeredUV = UV - 0.5;
	float distFromCenter = length(centeredUV);
	float distFromEdge = max((abs(centeredUV.x)),abs(centeredUV.y));
	float t = (sin(TIME) + 1.) * 0.25;
	float stepped = step(t,distFromEdge+noise);
	COLOR = vec4(vec3(stepped),1.-stepped);
}

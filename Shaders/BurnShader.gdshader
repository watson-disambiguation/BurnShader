shader_type canvas_item;

uniform sampler2D noiseTexture : source_color;
uniform float edgeWidth;
uniform float value;
float inverseLerp(float from, float to, float t) {
	return (t - from) / (from - to);
}

void fragment() {
	float noise = texture(noiseTexture,UV).x * 0.05;
	vec2 centeredUV = UV - 0.5;
	float distFromCenter = length(centeredUV);
	float distFromEdge = max((abs(centeredUV.x)),abs(centeredUV.y));
	float dist = distFromEdge+noise;
	
	float stepped = step(value,dist);
	float innerStepped = step(value-edgeWidth,dist);
	float burnedEdge = inverseLerp(value-edgeWidth,value,dist);
	COLOR = vec4(burnedEdge,0,0,1.0-stepped);
}

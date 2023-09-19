shader_type canvas_item;

uniform sampler2D noiseTexture : source_color;
uniform float edgeWidth;
uniform float value;
uniform float burnAngle;
uniform vec3 flameColor : source_color;
float inverseLerp(float from, float to, float t) {
	return (t - from) / (from - to);
}

void fragment() {
	float noise = texture(noiseTexture,vec2(UV.x,UV.y)).x * 0.05;
	vec2 centeredUV = UV - 0.5;
	float cornerProximity = abs(centeredUV.x) + abs(centeredUV.y);
	float angle = atan(centeredUV.y/centeredUV.x);
	if(centeredUV.x > 0.) {
		angle = -angle;
	}
	angle = angle + (PI/2.0);
	float distFromCenter = length(centeredUV);
	float distFromEdge = max((abs(centeredUV.x)),abs(centeredUV.y));
	
	float dist = mix(distFromCenter,distFromEdge,value/0.5);
	float unburnedEdge = 1.0 - step(value,dist);
	float stepped = step(value,dist+noise);
	float innerStepped = step(value-edgeWidth,dist+noise);
	float burnedEdge = inverseLerp(value,value+edgeWidth,dist+noise);
	float steppedAngle = 1.0-smoothstep(burnAngle, burnAngle-0.5,angle);
	float burnt = 1.0 - mix(burnedEdge,unburnedEdge,steppedAngle);
	vec3 colour = clamp(mix(vec3(0.0), flameColor,burnt),0.0,1);
	COLOR = vec4(colour,unburnedEdge);
}

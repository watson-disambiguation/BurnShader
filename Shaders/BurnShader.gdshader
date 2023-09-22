shader_type canvas_item;

uniform sampler2D noiseTexture : source_color;
uniform float noiseStrength;
uniform float progression;
uniform float initialSize;
uniform float midpointProgression;
uniform float innerEdgeWidth;
uniform float outerEdgeWidth;
uniform float falloffBurnAngle;
uniform float flameSpeed;
uniform vec3 flameColor : source_color;

float inverseLerp(float from, float to, float t) {
	return (t - from) / (to - from);
}



float clamp01(float x) {
	return clamp(x,0,1);
}

void fragment() { 
	// noise texture moves upward, to look like rising flickering flames
	float movingNoise = texture(noiseTexture,fract(vec2(UV.x,UV.y+TIME*flameSpeed))).x * 0.05;
	// static noise texture for static burn edges
	float noise = texture(noiseTexture,UV).x * noiseStrength;
	
	vec4 baseColour = vec4(1,1,1,0);
	
	// progression is remapped to control the burning along edges phase and the 
	// and the burning inward phase.
	float burnAngle = mix(-falloffBurnAngle,PI+falloffBurnAngle,clamp01(inverseLerp(0,midpointProgression,progression)));
	float value = clamp01(inverseLerp(midpointProgression,1.0,progression));
	// endpoint needs to be offset by edgewidth and noise strength
	// so flame completely disappears
	float burnIn = mix(initialSize,-outerEdgeWidth-noiseStrength,value);
	
	// signed distance fields
	vec2 centeredUV = UV - 0.5;	
	// circular sdf
	float distFromCenter = length(centeredUV);
	// rectangular sdf
	float distFromEdge = max((abs(centeredUV.x)),abs(centeredUV.y));
	// blended so sdf becomes more circular as burning continues
	float dist = mix(distFromCenter,distFromEdge,(1.0-value));
	//float dist = distFromEdge;

	
	
	// calculate angle to pixel, for use in burning along the edge
	float angle = atan(centeredUV.y/centeredUV.x);
	if(centeredUV.x > 0.) {
		angle = -angle;
	}
	angle = angle + (PI/2.0);
	
	// different stages of burning
	
	// for use before flame has spread around the edge
	float unburnedOuterEdge = 1.0 - step(burnIn,dist);
	// middle flickers someone, taking from both noise textures
	float burnedmiddleEdge = 1.0 - step(burnIn,dist+mix(movingNoise,noise,0.5));
	// outermost edge flickers a lot
	float burnedOuterEdge = 1.0 - step(burnIn+outerEdgeWidth,dist+movingNoise);
	// innermost edge is completely static
	float burnedInnerEdge = 1.0 - step(burnIn-innerEdgeWidth,dist+noise);
	
	vec4 colour = vec4(burnedmiddleEdge,burnedInnerEdge,burnedOuterEdge,burnedOuterEdge);
	
	// angle is used to divide burnt parts of the edge from unburnt parts
	float steppedAngle = 1.0-smoothstep(burnAngle-falloffBurnAngle, burnAngle,angle);
	vec4 unburnedColour = unburnedOuterEdge * baseColour + (1.0 - unburnedOuterEdge) * colour;
	unburnedColour.a = unburnedOuterEdge;
	colour = mix(unburnedColour,colour,steppedAngle);
	COLOR = colour;
	//COLOR = vec4(vec3(unburnedOuterEdge),1.0);
}

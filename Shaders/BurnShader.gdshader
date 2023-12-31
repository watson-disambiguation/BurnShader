shader_type canvas_item;

uniform sampler2D stillNoiseTex : source_color;
uniform sampler2D movingNoiseTex : source_color;
uniform float noiseStrength;
//uniform float progression;
uniform float initialSize;
uniform float midpointProgression;
uniform float innerEdgeWidth;
uniform float outerEdgeWidth;
uniform float falloffBurnAngle;
uniform float flameSpeed;
uniform vec4 innerFlameColor : source_color;
uniform vec4 outerFlameColor : source_color;
uniform vec4 ashColour : source_color;

/*
 *
 */
float inverseLerp(float from, float to, float t) {
	return (t - from) / (to - from);
}

/*
 *
 */
float clamp01(float x) {
	return clamp(x,0,1);
}

float restrict01(float x) {
	return x * float(x > 0.0) * float(x < 1.0);
}

void fragment() { 
	//time based progression for testing
	float progression = fract(0.25*TIME);
	// noise texture moves upward, to look like rising flickering flames
	float movingNoise = texture(movingNoiseTex,fract(vec2(UV.x,UV.y+TIME*flameSpeed))).x * 0.05;
	// static noise texture for static burn edges
	float stillNoise = texture(stillNoiseTex,UV).x * noiseStrength;
	
	vec4 baseColour = vec4(1);
	
	// progression is remapped to control the burning along edges phase and the 
	// and the burning inward phase.
	float burnAngle = mix(-falloffBurnAngle*noiseStrength,PI+falloffBurnAngle*noiseStrength,clamp01(inverseLerp(0,midpointProgression,progression)));
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
	
	// mix noise based on distance so outer edge flickers and inner edge is stationary
	float noiseLerp = clamp01(inverseLerp(burnIn-outerEdgeWidth,burnIn+innerEdgeWidth,dist));
	float noise = mix(stillNoise,movingNoise,noiseLerp);
	
	// different stages of burning
	
	// for use before flame has spread around the edge
	float unburnedOuterEdge = 1.0 - step(burnIn,dist);
	
	float burnedInnerEdge = restrict01(inverseLerp(burnIn-innerEdgeWidth,burnIn,dist+noise));
	float burnedOuterEdge = restrict01(inverseLerp(burnIn+outerEdgeWidth,burnIn,dist+noise));
	
	float inside = float(dist + noise < burnIn);
	
	vec4 burnedInnerEdgeColor = mix(ashColour,innerFlameColor,burnedInnerEdge);
	vec4 burnedOuterEdgeColor = mix(outerFlameColor,innerFlameColor,burnedOuterEdge);
	vec4 colour = burnedInnerEdgeColor * float(burnedInnerEdge > 0.0) 
			+ burnedOuterEdgeColor * float(burnedOuterEdge > 0.0);
	vec4 unburnedColour = unburnedOuterEdge * baseColour;
	colour = mix(baseColour*inside,colour,colour.a);
	
	// angle is used to divide burnt parts of the edge from unburnt parts
	float steppedAngle = 1.0-smoothstep(burnAngle-falloffBurnAngle*movingNoise, burnAngle,angle);

	colour = mix(unburnedColour,colour,steppedAngle);
	COLOR = colour;
	//COLOR = vec4(vec3(),1.0);
}

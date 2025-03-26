#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

//------------------------------------------------------------------------------------------------------
// Default Additional Lights
//------------------------------------------------------------------------------------------------------

/*
- Handles additional lights (e.g. point, spotlights)
- For custom lighting, you'd want to duplicate this and swap the LightingLambert / LightingSpecular functions out. See Toon Example below!
- For shadows to work in the Unlit Graph, the following keywords must be defined in the blackboard :
	- Boolean Keyword, Global Multi-Compile "_ADDITIONAL_LIGHT_SHADOWS"
	- Boolean Keyword, Global Multi-Compile "_ADDITIONAL_LIGHTS" (required to prevent the one above from being stripped from builds)
- For a PBR/Lit Graph, these keywords are already handled for you.
*/
void AdditionalLights_float(float3 SpecColor, float Smoothness, float3 WorldPosition, float3 WorldNormal, float3 WorldView, half4 Shadowmask,
							out float3 Direct, out float3 Translucent) {
	float3 directColor = 0;
	float3 translucentColor = 0;

#ifndef SHADERGRAPH_PREVIEW
	Smoothness = exp2(10 * Smoothness + 1);
	WorldNormal = normalize(WorldNormal);
	WorldView = SafeNormalize(WorldView);
	int pixelLightCount = GetAdditionalLightsCount();
	for (int i = 0; i < pixelLightCount; ++i) {
		Light light = GetAdditionalLight(i, WorldPosition, half4(1,1,1,1));

		float3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
		directColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
		directColor += LightingSpecular(attenuatedLightColor, light.direction, WorldNormal, WorldView, float4(SpecColor, 0), Smoothness);
		translucentColor += attenuatedLightColor;
		//specularColor += LightingSpecular(attenuatedLightColor, light.direction, WorldNormal, WorldView, float4(SpecColor, 0), Smoothness);
	}
#endif

	Direct = directColor;
	Translucent = translucentColor;
}

void AdditionalLights_float(float3 SpecColor, float Smoothness, float3 WorldPosition, float3 WorldNormal, float3 WorldView, 
							out float3 Direct, out float3 Translucent) {
AdditionalLights_float(SpecColor, Smoothness, WorldPosition, WorldNormal, WorldView, half4(1,1,1,1), Direct, Translucent);
}


#endif // CUSTOM_LIGHTING_INCLUDED
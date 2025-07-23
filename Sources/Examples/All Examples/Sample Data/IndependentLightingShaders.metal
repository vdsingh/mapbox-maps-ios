#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 texCoord [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float3 worldNormal;
    float2 texCoord;
};

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 viewProjectionMatrix;
    float3x3 normalMatrix;
    float3 cameraPosition;
};

struct LightData {
    float3 position;
    float3 color;
    float intensity;
    float attenuationRadius;
};

struct MaterialData {
    float3 albedo;
    float metallic;
    float roughness;
    float3 emissive;
};

vertex VertexOut lit_model_vertex_shader(VertexIn in [[stage_in]],
                                         constant Uniforms& uniforms [[buffer(1)]]) {
    VertexOut out;
    
    float4 worldPosition = uniforms.modelMatrix * float4(in.position, 1.0);
    out.worldPosition = worldPosition.xyz;
    out.position = uniforms.viewProjectionMatrix * worldPosition;
    out.worldNormal = normalize(uniforms.normalMatrix * in.normal);
    out.texCoord = in.texCoord;
    
    return out;
}

// Simplified PBR lighting calculation
float3 calculatePBRLighting(float3 worldPos, float3 normal, float3 viewDir, 
                           LightData light, MaterialData material) {
    // Light direction and distance
    float3 lightDir = light.position - worldPos;
    float lightDistance = length(lightDir);
    lightDir = normalize(lightDir);
    
    // Attenuation
    float attenuation = 1.0 / (1.0 + lightDistance * lightDistance / (light.attenuationRadius * light.attenuationRadius));
    attenuation = saturate(attenuation);
    
    // Basic Lambertian diffuse
    float NdotL = saturate(dot(normal, lightDir));
    float3 diffuse = material.albedo * NdotL;
    
    // Simple specular (Blinn-Phong approximation)
    float3 halfDir = normalize(lightDir + viewDir);
    float NdotH = saturate(dot(normal, halfDir));
    float specularPower = mix(32.0, 512.0, 1.0 - material.roughness);
    float3 specular = material.metallic * pow(NdotH, specularPower);
    
    // Combine lighting
    float3 lighting = (diffuse + specular) * light.color * light.intensity * attenuation;
    
    return lighting + material.emissive;
}

fragment float4 lit_model_fragment_shader(VertexOut in [[stage_in]],
                                          constant LightData& light [[buffer(0)]],
                                          constant MaterialData& material [[buffer(1)]],
                                          constant Uniforms& uniforms [[buffer(2)]]) {
    float3 normal = normalize(in.worldNormal);
    float3 viewDir = normalize(uniforms.cameraPosition - in.worldPosition);
    
    float3 color = calculatePBRLighting(in.worldPosition, normal, viewDir, light, material);
    
    return float4(color, 1.0);
} 
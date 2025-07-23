# Independent Lighting for 3D Models

This implementation provides complete independent lighting control for individual 3D models using Custom Metal shaders with the Mapbox Maps iOS SDK.

## Overview

Unlike the built-in `ModelLayer` which only supports global lighting controls, this custom implementation allows each 3D model to have its own lighting setup including:

- Individual point lights with custom position, color, intensity, and attenuation
- Per-model material properties (albedo, metallic, roughness, emissive)
- Real-time lighting updates
- Simplified PBR (Physically Based Rendering) lighting calculations

## Usage

### 1. Add the Example to Your Project

The `IndependentLightingExample` demonstrates three cubes with different lighting setups:
- Red light with standard material
- Blue light with metallic material
- Green light with rough, emissive material

### 2. Basic Implementation

```swift
// Create the custom layer host
let customLayerHost = IndependentLightingCustomLayerHost()

// Add it as a custom layer to your map
let customLayer = CustomLayer(id: "independent-lighting-layer", renderer: customLayerHost)
try mapView.mapboxMap.addLayer(customLayer, layerPosition: .default)

// Add a model with custom lighting
let lightData = IndependentLightingCustomLayerHost.LightData(
    position: simd_float3(0, 0, 10),     // 10 meters above the model
    color: simd_float3(1.0, 0.2, 0.2),  // Red light
    intensity: 5.0,
    attenuationRadius: 50.0
)

let materialData = IndependentLightingCustomLayerHost.MaterialData(
    albedo: simd_float3(0.8, 0.8, 0.8),  // Light gray base color
    metallic: 0.1,                       // Slightly metallic
    roughness: 0.3,                      // Moderately smooth
    emissive: simd_float3(0, 0, 0)       // No self-emission
)

let model = CustomLitModel(
    id: "my-model",
    coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
    altitude: 0,
    scale: simd_float3(10, 10, 10),
    lightData: lightData,
    materialData: materialData
)

customLayerHost.addModel(model)
```

### 3. Runtime Updates

You can update lighting properties in real-time:

```swift
// Update light intensity
let newLight = IndependentLightingCustomLayerHost.LightData(
    position: simd_float3(0, 0, 10),
    color: simd_float3(1.0, 0.2, 0.2),
    intensity: newIntensityValue,  // Changed value
    attenuationRadius: 50.0
)
customLayerHost.updateModelLighting(id: "my-model", lightData: newLight)
```

## Key Features

### Lighting Properties

- **Position**: 3D world position of the light source relative to the model
- **Color**: RGB color values (0.0 to 1.0 range)
- **Intensity**: Light brightness multiplier
- **Attenuation Radius**: Distance over which light diminishes

### Material Properties

- **Albedo**: Base surface color (RGB)
- **Metallic**: How metallic the surface appears (0.0 = dielectric, 1.0 = metallic)
- **Roughness**: Surface roughness (0.0 = mirror, 1.0 = completely rough)
- **Emissive**: Self-emitted light color (for glowing effects)

### Rendering Features

- **PBR-style lighting**: Simplified physically-based rendering for realistic results
- **Distance attenuation**: Lights fade naturally with distance
- **Specular highlights**: Reflective highlights based on material properties
- **Emissive materials**: Self-glowing surfaces
- **Real-time updates**: Change lighting properties on the fly

## Technical Details

### Metal Shaders

The implementation uses custom Metal shaders:
- `lit_model_vertex_shader`: Transforms vertices to world space
- `lit_model_fragment_shader`: Calculates PBR lighting per pixel

### Performance

- Each model renders in its own draw call for maximum flexibility
- Efficient vertex/index buffer sharing for the same geometry
- Minimal CPU overhead for lighting calculations (done in GPU)

### Coordinate System

- Model positions use geographic coordinates (latitude/longitude)
- Light positions are relative to the model in meters
- Automatic integration with Mapbox's projection system

## Limitations

- Currently renders simple cube geometry (can be extended to load custom models)
- Single light per model (can be extended to multiple lights)
- Simplified PBR implementation (can be enhanced with more complex materials)
- Requires Metal support (iOS 8+ with compatible hardware)

## Extension Ideas

1. **Multiple Lights**: Extend the shader to support multiple lights per model
2. **Shadows**: Add shadow mapping for more realistic lighting
3. **Model Loading**: Support for glTF/OBJ model loading
4. **Animation**: Animate light positions and model transformations
5. **Environmental Lighting**: Add ambient lighting and image-based lighting
6. **Post-processing**: Add bloom effects for emissive materials

This implementation demonstrates the power of custom Metal rendering within the Mapbox ecosystem while maintaining seamless integration with the map's projection and rendering pipeline. 
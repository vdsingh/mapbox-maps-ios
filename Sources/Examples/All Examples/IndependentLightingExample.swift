import UIKit
import MapboxMaps
import Metal
import MetalKit

final class IndependentLightingExample: UIViewController, ExampleProtocol {
    
    private var mapView: MapView!
    private var customLayerHost: IndependentLightingCustomLayerHost!
    private var cancelables = Set<AnyCancelable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cameraOptions = CameraOptions(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            zoom: 16,
            pitch: 60
        )
        
        mapView = MapView(frame: view.bounds, mapInitOptions: MapInitOptions(cameraOptions: cameraOptions))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
        mapView.mapboxMap.onStyleLoaded.observeNext { [weak self] _ in
            self?.setupCustomModelsWithLighting()
        }.store(in: &cancelables)
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        finish()
    }
    
    private func setupCustomModelsWithLighting() {
        customLayerHost = IndependentLightingCustomLayerHost()
        
        let customLayer = CustomLayer(id: "independent-lighting-layer", renderer: customLayerHost)
        
        do {
            try mapView.mapboxMap.addLayer(customLayer, layerPosition: .default)
        } catch {
            print("Failed to add custom layer: \(error)")
        }
        
        // Add models with different lighting setups
        addModelWithRedLight()
        addModelWithBlueLight()
        addModelWithGreenLight()
    }
    
    private func addModelWithRedLight() {
        let redLight = IndependentLightingCustomLayerHost.LightData(
            position: simd_float3(0, 0, 10),     // 10 meters above the model
            color: simd_float3(1.0, 0.2, 0.2),  // Red light
            intensity: 5.0,
            attenuationRadius: 50.0
        )
        
        let material = IndependentLightingCustomLayerHost.MaterialData(
            albedo: simd_float3(0.8, 0.8, 0.8),  // Light gray base
            metallic: 0.1,
            roughness: 0.3,
            emissive: simd_float3(0, 0, 0)       // No self-emission
        )
        
        let model = CustomLitModel(
            id: "red-lit-model",
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            altitude: 0,
            scale: simd_float3(10, 10, 10),
            lightData: redLight,
            materialData: material
        )
        
        customLayerHost.addModel(model)
    }
    
    private func addModelWithBlueLight() {
        let blueLight = IndependentLightingCustomLayerHost.LightData(
            position: simd_float3(-5, 5, 15),    // Offset blue light
            color: simd_float3(0.2, 0.2, 1.0),  // Blue light
            intensity: 8.0,
            attenuationRadius: 30.0
        )
        
        let material = IndependentLightingCustomLayerHost.MaterialData(
            albedo: simd_float3(0.9, 0.9, 0.9),
            metallic: 0.7,                       // More metallic
            roughness: 0.1,                      // Very smooth
            emissive: simd_float3(0, 0, 0.1)     // Slight blue glow
        )
        
        let model = CustomLitModel(
            id: "blue-lit-model",
            coordinate: CLLocationCoordinate2D(latitude: 37.7759, longitude: -122.4184),
            altitude: 0,
            scale: simd_float3(15, 15, 15),
            lightData: blueLight,
            materialData: material
        )
        
        customLayerHost.addModel(model)
    }
    
    private func addModelWithGreenLight() {
        let greenLight = IndependentLightingCustomLayerHost.LightData(
            position: simd_float3(3, -3, 8),     // Different angle
            color: simd_float3(0.2, 1.0, 0.2),  // Green light
            intensity: 3.0,
            attenuationRadius: 80.0              // Wider spread
        )
        
        let material = IndependentLightingCustomLayerHost.MaterialData(
            albedo: simd_float3(0.7, 0.7, 0.7),
            metallic: 0.0,                       // Non-metallic
            roughness: 0.8,                      // Rough surface
            emissive: simd_float3(0.1, 0.3, 0.1) // Green emissive glow
        )
        
        let model = CustomLitModel(
            id: "green-lit-model",
            coordinate: CLLocationCoordinate2D(latitude: 37.7739, longitude: -122.4204),
            altitude: 0,
            scale: simd_float3(8, 8, 8),
            lightData: greenLight,
            materialData: material
        )
        
        customLayerHost.addModel(model)
    }
    
    private func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        stackView.layer.cornerRadius = 8
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        // Red light intensity slider
        let redLabel = UILabel()
        redLabel.text = "Red Light Intensity"
        redLabel.textColor = .white
        redLabel.font = .systemFont(ofSize: 14)
        
        let redSlider = UISlider()
        redSlider.minimumValue = 0
        redSlider.maximumValue = 10
        redSlider.value = 5
        redSlider.addTarget(self, action: #selector(updateRedLightIntensity(_:)), for: .valueChanged)
        
        // Blue light intensity slider
        let blueLabel = UILabel()
        blueLabel.text = "Blue Light Intensity"
        blueLabel.textColor = .white
        blueLabel.font = .systemFont(ofSize: 14)
        
        let blueSlider = UISlider()
        blueSlider.minimumValue = 0
        blueSlider.maximumValue = 10
        blueSlider.value = 8
        blueSlider.addTarget(self, action: #selector(updateBlueLightIntensity(_:)), for: .valueChanged)
        
        // Green light intensity slider
        let greenLabel = UILabel()
        greenLabel.text = "Green Light Intensity"
        greenLabel.textColor = .white
        greenLabel.font = .systemFont(ofSize: 14)
        
        let greenSlider = UISlider()
        greenSlider.minimumValue = 0
        greenSlider.maximumValue = 10
        greenSlider.value = 3
        greenSlider.addTarget(self, action: #selector(updateGreenLightIntensity(_:)), for: .valueChanged)
        
        stackView.addArrangedSubview(redLabel)
        stackView.addArrangedSubview(redSlider)
        stackView.addArrangedSubview(blueLabel)
        stackView.addArrangedSubview(blueSlider)
        stackView.addArrangedSubview(greenLabel)
        stackView.addArrangedSubview(greenSlider)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func updateRedLightIntensity(_ sender: UISlider) {
        guard customLayerHost != nil else { return }
        let newLight = IndependentLightingCustomLayerHost.LightData(
            position: simd_float3(0, 0, 10),
            color: simd_float3(1.0, 0.2, 0.2),
            intensity: sender.value,
            attenuationRadius: 50.0
        )
        customLayerHost.updateModelLighting(id: "red-lit-model", lightData: newLight)
    }
    
    @objc private func updateBlueLightIntensity(_ sender: UISlider) {
        guard customLayerHost != nil else { return }
        let newLight = IndependentLightingCustomLayerHost.LightData(
            position: simd_float3(-5, 5, 15),
            color: simd_float3(0.2, 0.2, 1.0),
            intensity: sender.value,
            attenuationRadius: 30.0
        )
        customLayerHost.updateModelLighting(id: "blue-lit-model", lightData: newLight)
    }
    
    @objc private func updateGreenLightIntensity(_ sender: UISlider) {
        guard customLayerHost != nil else { return }
        let newLight = IndependentLightingCustomLayerHost.LightData(
            position: simd_float3(3, -3, 8),
            color: simd_float3(0.2, 1.0, 0.2),
            intensity: sender.value,
            attenuationRadius: 80.0
        )
        customLayerHost.updateModelLighting(id: "green-lit-model", lightData: newLight)
    }
}

// MARK: - Custom Layer Host Implementation

final class IndependentLightingCustomLayerHost: NSObject, CustomLayerHost {
    
    // Metal resources
    private var device: MTLDevice!
    private var commandQueue: MTLCommandQueue!
    private var renderPipelineState: MTLRenderPipelineState!
    private var depthStencilState: MTLDepthStencilState!
    
    // Model data
    private var models: [CustomLitModel] = []
    private var vertexBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    private var indexCount: Int = 0
    
    // Shader uniforms
    struct Uniforms {
        var modelMatrix: simd_float4x4
        var viewProjectionMatrix: simd_float4x4
        var normalMatrix: simd_float3x3
        var cameraPosition: simd_float3
    }
    
    struct LightData {
        var position: simd_float3       // Light position in world space
        var color: simd_float3         // Light color (RGB)
        var intensity: Float           // Light intensity
        var attenuationRadius: Float   // How far the light reaches
    }
    
    struct MaterialData {
        var albedo: simd_float3        // Base color
        var metallic: Float            // Metallic factor
        var roughness: Float           // Surface roughness
        var emissive: simd_float3      // Self-emitted light
    }
    
    override init() {
        super.init()
    }
    
    func renderingWillStart(_ metalDevice: MTLDevice, colorPixelFormat: UInt, depthStencilPixelFormat: UInt) {
        device = metalDevice
        commandQueue = device.makeCommandQueue()!
        
        setupRenderPipeline(colorPixelFormat: colorPixelFormat, depthStencilPixelFormat: depthStencilPixelFormat)
        setupDepthStencil()
        loadDefaultModel()
    }
    
    func renderingWillEnd() {
        // Cleanup if needed
    }
    
    func render(_ parameters: CustomLayerRenderParameters, mtlCommandBuffer: MTLCommandBuffer, mtlRenderPassDescriptor: MTLRenderPassDescriptor) {
        
        guard let renderEncoder = mtlCommandBuffer.makeRenderCommandEncoder(descriptor: mtlRenderPassDescriptor) else {
            return
        }
        
        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setDepthStencilState(depthStencilState)
        
        let projectionMatrix = parameters.projectionMatrix.simdFloat4x4
        
        // Render each model with its own lighting
        for model in models {
            renderModel(model, projectionMatrix: projectionMatrix, parameters: parameters, encoder: renderEncoder)
        }
        
        renderEncoder.endEncoding()
    }
    
    private func setupRenderPipeline(colorPixelFormat: UInt, depthStencilPixelFormat: UInt) {
        // Create a simple shader source since we can't load external files
        let shaderSource = """
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
        
        float3 calculatePBRLighting(float3 worldPos, float3 normal, float3 viewDir, 
                                   LightData light, MaterialData material) {
            float3 lightDir = light.position - worldPos;
            float lightDistance = length(lightDir);
            lightDir = normalize(lightDir);
            
            float attenuation = 1.0 / (1.0 + lightDistance * lightDistance / (light.attenuationRadius * light.attenuationRadius));
            attenuation = saturate(attenuation);
            
            float NdotL = saturate(dot(normal, lightDir));
            float3 diffuse = material.albedo * NdotL;
            
            float3 halfDir = normalize(lightDir + viewDir);
            float NdotH = saturate(dot(normal, halfDir));
            float specularPower = mix(32.0, 512.0, 1.0 - material.roughness);
            float3 specular = material.metallic * pow(NdotH, specularPower);
            
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
        """
        
        // Create library from source
        let library: MTLLibrary
        do {
            library = try device.makeLibrary(source: shaderSource, options: nil)
        } catch {
            print("Failed to create shader library: \(error)")
            // Fallback to a simple colored cube
            createFallbackPipeline(colorPixelFormat: colorPixelFormat, depthStencilPixelFormat: depthStencilPixelFormat)
            return
        }
        
        let vertexFunction = library.makeFunction(name: "lit_model_vertex_shader")!
        let fragmentFunction = library.makeFunction(name: "lit_model_fragment_shader")!
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat(rawValue: colorPixelFormat)!
        pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormat(rawValue: depthStencilPixelFormat)!
        
        // Enable blending
        let colorAttachment = pipelineDescriptor.colorAttachments[0]!
        colorAttachment.isBlendingEnabled = true
        colorAttachment.rgbBlendOperation = .add
        colorAttachment.alphaBlendOperation = .add
        colorAttachment.sourceRGBBlendFactor = .sourceAlpha
        colorAttachment.sourceAlphaBlendFactor = .sourceAlpha
        colorAttachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        colorAttachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        // Set up vertex descriptor
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3      // position
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.attributes[1].format = .float3      // normal
        vertexDescriptor.attributes[1].offset = 12
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.attributes[2].format = .float2      // texCoord
        vertexDescriptor.attributes[2].offset = 24
        vertexDescriptor.attributes[2].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = 32
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Failed to create render pipeline state: \(error)")
            createFallbackPipeline(colorPixelFormat: colorPixelFormat, depthStencilPixelFormat: depthStencilPixelFormat)
        }
    }
    
    private func createFallbackPipeline(colorPixelFormat: UInt, depthStencilPixelFormat: UInt) {
        // Create a simple fallback shader source
        let fallbackShaderSource = """
        #include <metal_stdlib>
        using namespace metal;
        
        struct VertexIn {
            float3 position [[attribute(0)]];
            float3 normal [[attribute(1)]];
            float2 texCoord [[attribute(2)]];
        };
        
        struct VertexOut {
            float4 position [[position]];
            float3 color;
        };
        
        struct Uniforms {
            float4x4 modelMatrix;
            float4x4 viewProjectionMatrix;
            float3x3 normalMatrix;
            float3 cameraPosition;
        };
        
        vertex VertexOut vertex_main(VertexIn in [[stage_in]],
                                    constant Uniforms& uniforms [[buffer(1)]]) {
            VertexOut out;
            float4 worldPosition = uniforms.modelMatrix * float4(in.position, 1.0);
            out.position = uniforms.viewProjectionMatrix * worldPosition;
            // Simple color based on normal
            out.color = abs(in.normal);
            return out;
        }
        
        fragment float4 fragment_main(VertexOut in [[stage_in]]) {
            return float4(in.color, 1.0);
        }
        """
        
        let library: MTLLibrary
        do {
            library = try device.makeLibrary(source: fallbackShaderSource, options: nil)
        } catch {
            fatalError("Failed to create fallback shader library: \(error)")
        }
        
        let vertexFunction = library.makeFunction(name: "vertex_main")!
        let fragmentFunction = library.makeFunction(name: "fragment_main")!
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat(rawValue: colorPixelFormat)!
        pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormat(rawValue: depthStencilPixelFormat)!
        
        // Set up vertex descriptor for fallback
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = 12
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].offset = 24
        vertexDescriptor.attributes[2].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = 32
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        renderPipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private func setupDepthStencil() {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
    }
    
    private func loadDefaultModel() {
        // Create a cube with normals
        let vertices: [Float] = [
            // Front face (z = 0.5)
            -0.5, -0.5,  0.5,  0.0,  0.0,  1.0,  0.0, 0.0,  // position, normal, texCoord
             0.5, -0.5,  0.5,  0.0,  0.0,  1.0,  1.0, 0.0,
             0.5,  0.5,  0.5,  0.0,  0.0,  1.0,  1.0, 1.0,
            -0.5,  0.5,  0.5,  0.0,  0.0,  1.0,  0.0, 1.0,
            
            // Back face (z = -0.5)
            -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,  1.0, 0.0,
             0.5, -0.5, -0.5,  0.0,  0.0, -1.0,  0.0, 0.0,
             0.5,  0.5, -0.5,  0.0,  0.0, -1.0,  0.0, 1.0,
            -0.5,  0.5, -0.5,  0.0,  0.0, -1.0,  1.0, 1.0,
            
            // Left face (x = -0.5)
            -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,  0.0, 0.0,
            -0.5, -0.5,  0.5, -1.0,  0.0,  0.0,  1.0, 0.0,
            -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,  1.0, 1.0,
            -0.5,  0.5, -0.5, -1.0,  0.0,  0.0,  0.0, 1.0,
            
            // Right face (x = 0.5)
             0.5, -0.5, -0.5,  1.0,  0.0,  0.0,  1.0, 0.0,
             0.5, -0.5,  0.5,  1.0,  0.0,  0.0,  0.0, 0.0,
             0.5,  0.5,  0.5,  1.0,  0.0,  0.0,  0.0, 1.0,
             0.5,  0.5, -0.5,  1.0,  0.0,  0.0,  1.0, 1.0,
            
            // Top face (y = 0.5)
            -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,  0.0, 1.0,
            -0.5,  0.5,  0.5,  0.0,  1.0,  0.0,  0.0, 0.0,
             0.5,  0.5,  0.5,  0.0,  1.0,  0.0,  1.0, 0.0,
             0.5,  0.5, -0.5,  0.0,  1.0,  0.0,  1.0, 1.0,
            
            // Bottom face (y = -0.5)
            -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,  1.0, 1.0,
            -0.5, -0.5,  0.5,  0.0, -1.0,  0.0,  1.0, 0.0,
             0.5, -0.5,  0.5,  0.0, -1.0,  0.0,  0.0, 0.0,
             0.5, -0.5, -0.5,  0.0, -1.0,  0.0,  0.0, 1.0,
        ]
        
        let indices: [UInt16] = [
            // Front face
            0, 1, 2,  2, 3, 0,
            // Back face
            4, 6, 5,  6, 4, 7,
            // Left face
            8, 9, 10,  10, 11, 8,
            // Right face
            12, 14, 13,  14, 12, 15,
            // Top face
            16, 17, 18,  18, 19, 16,
            // Bottom face
            20, 22, 21,  22, 20, 23
        ]
        
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.size, options: [])!
        indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])!
        indexCount = indices.count
    }
    
    private func renderModel(_ model: CustomLitModel, projectionMatrix: simd_float4x4, parameters: CustomLayerRenderParameters, encoder: MTLRenderCommandEncoder) {
        
        // Create model matrix for positioning
        let modelMatrix = parameters.createModelMatrixMeters(
            location: model.coordinate,
            altitude: model.altitude,
            size: model.scale
        )
        
        var uniforms = Uniforms(
            modelMatrix: modelMatrix.simdFloat4x4,
            viewProjectionMatrix: projectionMatrix,
            normalMatrix: simd_float3x3(modelMatrix.simdFloat4x4.upperLeft3x3.transpose.inverse),
            cameraPosition: simd_float3(0, 0, 0)
        )
        
        // Set buffers
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 1)
        
        // Try to set lighting data (may fail if using fallback shader)
        var lightData = model.lightData
        var materialData = model.materialData
        encoder.setFragmentBytes(&lightData, length: MemoryLayout<LightData>.size, index: 0)
        encoder.setFragmentBytes(&materialData, length: MemoryLayout<MaterialData>.size, index: 1)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 2)
        
        // Draw
        encoder.drawIndexedPrimitives(type: .triangle, indexCount: indexCount, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
    }
    
    // Public API to manage models
    func addModel(_ model: CustomLitModel) {
        models.append(model)
    }
    
    func removeModel(id: String) {
        models.removeAll { $0.id == id }
    }
    
    func updateModelLighting(id: String, lightData: LightData) {
        if let index = models.firstIndex(where: { $0.id == id }) {
            models[index].lightData = lightData
        }
    }
}

// MARK: - Model Data Structure

struct CustomLitModel {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let altitude: Double
    let scale: simd_float3
    var lightData: IndependentLightingCustomLayerHost.LightData
    var materialData: IndependentLightingCustomLayerHost.MaterialData
}

// MARK: - Extensions

extension simd_float4x4 {
    var upperLeft3x3: simd_float3x3 {
        let col1 = simd_float3(columns.0.x, columns.0.y, columns.0.z)
        let col2 = simd_float3(columns.1.x, columns.1.y, columns.1.z)
        let col3 = simd_float3(columns.2.x, columns.2.y, columns.2.z)
        return simd_float3x3(col1, col2, col3)
    }
}

extension simd_float3x3 {
    var transpose: simd_float3x3 {
        return simd_float3x3(
            simd_float3(columns.0.x, columns.1.x, columns.2.x),
            simd_float3(columns.0.y, columns.1.y, columns.2.y),
            simd_float3(columns.0.z, columns.1.z, columns.2.z)
        )
    }
    
    var inverse: simd_float3x3 {
        let det = determinant
        if abs(det) < 1e-6 { return simd_float3x3(1.0) }
        
        let invDet = 1.0 / det
        return simd_float3x3(
            simd_float3(
                (columns.1.y * columns.2.z - columns.1.z * columns.2.y) * invDet,
                (columns.0.z * columns.2.y - columns.0.y * columns.2.z) * invDet,
                (columns.0.y * columns.1.z - columns.0.z * columns.1.y) * invDet
            ),
            simd_float3(
                (columns.1.z * columns.2.x - columns.1.x * columns.2.z) * invDet,
                (columns.0.x * columns.2.z - columns.0.z * columns.2.x) * invDet,
                (columns.0.z * columns.1.x - columns.0.x * columns.1.z) * invDet
            ),
            simd_float3(
                (columns.1.x * columns.2.y - columns.1.y * columns.2.x) * invDet,
                (columns.0.y * columns.2.x - columns.0.x * columns.2.y) * invDet,
                (columns.0.x * columns.1.y - columns.0.y * columns.1.x) * invDet
            )
        )
    }
    
    private var determinant: Float {
        return columns.0.x * (columns.1.y * columns.2.z - columns.1.z * columns.2.y) -
               columns.0.y * (columns.1.x * columns.2.z - columns.1.z * columns.2.x) +
               columns.0.z * (columns.1.x * columns.2.y - columns.1.y * columns.2.x)
    }
} 
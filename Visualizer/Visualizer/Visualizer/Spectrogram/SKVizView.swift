import SceneKit

class SKVizView: SCNView, VisualizerViewProtocol {
    
    var data: FrequencyData!
    let magnitudeRange: ClosedRange<Float> = 0...1
    
    func update(with data: FrequencyData) {
        
        self.data = data
        data.magnitudes = data.magnitudes.map {(mag: Float) -> Float in mag.clamp(to: magnitudeRange)}
        
        if AppDelegate.play {
        
            DispatchQueue.main.async {
                self.update()
            }
        }
    }
    
//    var cameraNode: SCNNode!
//    var camera: SCNCamera!
    
    var sbars: [SpectrogramBar] = []
    
    var floorNode: SCNNode!
    var floor: SCNFloor!
    
    let piOver180: CGFloat = CGFloat.pi / 180
    
    let maxBarHt: CGFloat = 3.6
    let barThickness: CGFloat = 0.25
    
    override func awakeFromNib() {
        
        AppDelegate.play = true
        
        scene = SCNScene()
        scene?.background.contents = NSColor.black
        
        // MARK: Camera ---------------------------------------

//        camera = SCNCamera()
//        cameraNode = SCNNode()
//
//        cameraNode.camera = camera
//        cameraNode.position = SCNVector3(x: 2.2, y: 1.6, z: 4)
////        cameraNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w: 4 * piOver180)
////
////        cameraNode.position = SCNVector3(x: 2.5, y: 1.3, z: 5.5)
//
//        scene!.rootNode.addChildNode(cameraNode)
        
        // MARK: Bar ---------------------------------------
        
        SCNTransaction.begin()
        
        for i in 0..<10 {
            
            let magnitude: CGFloat = CGFloat(i + 1) * 0.1
            
            let bar = SpectrogramBar(position: SCNVector3(CGFloat(i * 2) * barThickness, 0, 0),
                                     magnitude: magnitude,
                                     thickness: barThickness)
            
            sbars.append(bar)
            scene!.rootNode.addChildNode(bar.node)
        }
        
        SCNTransaction.commit()
        
        // MARK: Floor ---------------------------------------
        
        floor = SCNFloor()
        floor.firstMaterial?.diffuse.contents = NSColor.black
        floor.firstMaterial?.lightingModel = .physicallyBased

        floorNode = SCNNode(geometry: floor)
        scene!.rootNode.addChildNode(floorNode)

        // MARK: Scene settings ---------------------------------------
        antialiasingMode = .multisampling4X
        isJitteringEnabled = true
        allowsCameraControl = true
        autoenablesDefaultLighting = false
        showsStatistics = false
    }
    
    func update() {
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0
        
        for i in 0..<10 {
            sbars[i].magnitude = CGFloat(data.magnitudes[i])
        }
            
        SCNTransaction.commit()
    }
}

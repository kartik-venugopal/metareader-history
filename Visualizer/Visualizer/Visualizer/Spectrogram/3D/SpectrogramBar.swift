import SceneKit

class SpectrogramBar {
    
    static var startColor: NSColor = .green
    static var endColor: NSColor = .red
    
    static let bottomMaterial: SCNMaterial = {
        
        let material = SCNMaterial()
        material.diffuse.contents = NSColor.black
        return material
    }()
    
    let box: SCNBox
    let node: SCNNode
    
    private let sideGradientMaterial = SCNMaterial()
    private let topMaterial = SCNMaterial()
    
    static let maxHeight: CGFloat = 3.6
    
    var gradientImage: NSImage {
        
        didSet {
            sideGradientMaterial.diffuse.contents = gradientImage
        }
    }
    
    var magnitude: CGFloat {
        
        didSet {
            
            box.height = min(Self.maxHeight, magnitude * Self.maxHeight)
            node.pivot = SCNMatrix4MakeTranslation(0, -(box.height / 2), 0)
            
            let scale = SCNMatrix4MakeScale(1, box.height / Self.maxHeight, 1)
            sideGradientMaterial.diffuse.contentsTransform = SCNMatrix4Translate(scale, 0, (Self.maxHeight - box.height) / Self.maxHeight, 0)
            
            box.materials[4] = topMaterial
            topMaterial.diffuse.contents = Self.startColor.interpolate(Self.endColor, magnitude)
        }
    }
    
    init(position: SCNVector3, magnitude: CGFloat = 0, thickness: CGFloat, gradientImage: NSImage) {
        
        self.magnitude = magnitude
        let height = min(Self.maxHeight, magnitude * Self.maxHeight)
        self.box = SCNBox(width: thickness, height: height, length: thickness, chamferRadius: 0)
        
        self.node = SCNNode(geometry: box)
        self.node.position = position
        self.node.pivot = SCNMatrix4MakeTranslation(0, -(height / 2), 0)
        
        self.gradientImage = gradientImage
        self.sideGradientMaterial.diffuse.contents = self.gradientImage
        
        self.box.materials = [sideGradientMaterial, sideGradientMaterial, sideGradientMaterial, sideGradientMaterial, topMaterial, Self.bottomMaterial]
        
        let scale = SCNMatrix4MakeScale(1, box.height / Self.maxHeight, 1)
        sideGradientMaterial.diffuse.contentsTransform = SCNMatrix4Translate(scale, 0, (Self.maxHeight - box.height) / Self.maxHeight, 0)
        
        box.materials[4] = topMaterial
        topMaterial.diffuse.contents = Self.startColor.interpolate(Self.endColor, magnitude)
    }
}

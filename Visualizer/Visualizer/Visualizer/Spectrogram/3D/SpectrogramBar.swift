import SceneKit

class SpectrogramBar {
    
    static let sideColorMaterial: SCNMaterial = {
        
        let material = SCNMaterial()
        material.diffuse.contents = NSColor.green
        return material
    }()
    
    static let bottomMaterial: SCNMaterial = {
        
        let material = SCNMaterial()
        material.diffuse.contents = NSColor.black
        return material
    }()
    
    static let gradientImage: NSImage = NSImage(named: "Sp-Gradient")!
    
    let box: SCNBox
    let node: SCNNode
    
    private let sideGradientMaterial = SCNMaterial()
    private let topMaterial = SCNMaterial()
    
    static let maxHeight: CGFloat = 3.6
    
    var magnitude: CGFloat {
        
        didSet {
            
            box.height = min(Self.maxHeight, magnitude * Self.maxHeight)
            node.pivot = SCNMatrix4MakeTranslation(0, -(box.height / 2), 0)
            
            if magnitude <= 0.3 {
                
                for i in 0...4 {
                    box.materials[i] = Self.sideColorMaterial
                }
                
            } else {
                
                if box.materials[0] !== sideGradientMaterial {
                    
                    for i in 0...3 {
                        box.materials[i] = sideGradientMaterial
                    }
                }
                
                let scale = SCNMatrix4MakeScale(1, box.height / Self.maxHeight, 1)
                sideGradientMaterial.diffuse.contentsTransform = SCNMatrix4Translate(scale, 0, (Self.maxHeight - box.height) / Self.maxHeight, 0)
                
                box.materials[4] = topMaterial
                topMaterial.diffuse.contents = NSColor(red: magnitude, green: 1.0 - magnitude, blue: 0, alpha: 1)
            }
        }
    }
    
    init(position: SCNVector3, magnitude: CGFloat = 0, thickness: CGFloat) {
        
        self.magnitude = magnitude
        let height = min(Self.maxHeight, magnitude * Self.maxHeight)
        self.box = SCNBox(width: thickness, height: height, length: thickness, chamferRadius: 0)
        
        self.node = SCNNode(geometry: box)
        self.node.position = position
        self.node.pivot = SCNMatrix4MakeTranslation(0, -(height / 2), 0)
        
        self.sideGradientMaterial.diffuse.contents = Self.gradientImage
        self.box.materials = [Self.sideColorMaterial, Self.sideColorMaterial, Self.sideColorMaterial, Self.sideColorMaterial, Self.sideColorMaterial, Self.bottomMaterial]
        
        if magnitude > 0.3 {
            
            for i in 0...3 {
                box.materials[i] = sideGradientMaterial
            }
            
            let scale = SCNMatrix4MakeScale(1, box.height / Self.maxHeight, 1)
            sideGradientMaterial.diffuse.contentsTransform = SCNMatrix4Translate(scale, 0, (Self.maxHeight - box.height) / Self.maxHeight, 0)
            
            box.materials[4] = topMaterial
            topMaterial.diffuse.contents = NSColor(red: magnitude, green: 1.0 - magnitude, blue: 0, alpha: 1)
        }
    }
}

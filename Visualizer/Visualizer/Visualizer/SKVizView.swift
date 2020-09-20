import SceneKit
import SpriteKit

class SKVizView: SCNView, VisualizerViewProtocol {
    
    @IBOutlet weak var cropPreview: NSImageView!
    
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
    
    var bars: [SCNBox] = []
    var barNodes: [SCNNode] = []
    
    var cameraNode: SCNNode!
    var camera: SCNCamera!
    
    var floorNode: SCNNode!
    var floor: SCNFloor!
    
    let piOver180: CGFloat = CGFloat.pi / 180
    
    let maxBarHt: CGFloat = 4
    let barThickness: CGFloat = 0.25
    
    let spImage = NSImage(named: "Sp-Gradient")!
    lazy var imgWd: CGFloat = spImage.size.width
    lazy var imgHt: CGFloat = spImage.size.height
    
    override func awakeFromNib() {
        
        AppDelegate.play = true
        
        scene = SCNScene()
        scene?.background.contents = NSColor(calibratedWhite: 0.05, alpha: 1)
        
        // MARK: Camera ---------------------------------------

        camera = SCNCamera()
        cameraNode = SCNNode()
        
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 2, z: 0)
        cameraNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w: 4 * piOver180)
        
        cameraNode.position = SCNVector3(x: 2.5, y: 1.3, z: 5.5)
        
        scene!.rootNode.addChildNode(cameraNode)
        
        // MARK: Bar ---------------------------------------
        
        SCNTransaction.begin()
        
        for i in 0..<10 {
            
            let ht: CGFloat = CGFloat(i + 1) * maxBarHt / 10
            
            let bar = SCNBox(width: barThickness, height: ht, length: barThickness, chamferRadius: 0.05)
            bar.materials = [SCNMaterial(), SCNMaterial(), SCNMaterial(), SCNMaterial(), SCNMaterial(), bottomMaterial]
            materialsForBar(bar, ht / maxBarHt)
            
            // --------------
            
            let barNode = SCNNode(geometry: bar)
            barNode.position = SCNVector3(CGFloat(i * 2) * barThickness, 0, 0)
            barNode.pivot = SCNMatrix4MakeTranslation(0, -(bar.height / 2), 0) // new height
            
            bars.append(bar)
            barNodes.append(barNode)
            
            scene!.rootNode.addChildNode(barNode)
        }
        
        SCNTransaction.commit()
        
        cropPreview.image = bars[9].materials[0].diffuse.contents as? NSImage

        // MARK: Floor ---------------------------------------
        
        floor = SCNFloor()
        floor.reflectionCategoryBitMask = 4
        floor.firstMaterial?.diffuse.contents = NSColor(calibratedWhite: 0.05, alpha: 1)
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
    
    let bottomMaterial: SCNMaterial = {
       
        let matl = SCNMaterial()
        matl.diffuse.contents = NSColor.black
        return matl
    }()
    
    func materialsForBar(_ bar: SCNBox, _ magn: CGFloat) {
        
        let crop = NSImage(size: NSSize(width: imgWd, height: magn == 0 ? 1 : imgHt * magn))
        crop.lockFocus()
        let drawRect = NSRect(origin: NSPoint.zero, size: crop.size)
        spImage.draw(in: drawRect, from: drawRect, operation: .copy, fraction: 1)
        crop.unlockFocus()
        
        for index in 0...3 {
            bar.materials[index].diffuse.contents = crop
        }
        
        bar.materials[4].diffuse.contents = NSColor.green.interpolate(NSColor.red, magn).cgColor
    }
    
    func update() {
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0
        
        for i in 0..<10 {
            
            let magn = CGFloat(data.magnitudes[i])
            let height: CGFloat = min(maxBarHt, magn * maxBarHt)
            
            let bar = bars[i]
            let barNode = barNodes[i]
            
            bar.height = height
            barNode.pivot = SCNMatrix4MakeTranslation(0, -(bar.height / 2), 0) // new height
            materialsForBar(bar, magn)
        }
            
        SCNTransaction.commit()
    }
}

extension NSColor{
    /**
     * Interpolates between two NSColors
     * EXAMPLE: NSColor.green.interpolate(.blue, 0.5)
     * NOTE: There is also a native alternative: NSColor.green.blended(withFraction: 0.5, of: .blue)
     */
    func interpolate(_ to:NSColor,_ scalar:CGFloat)->NSColor{
        
        func interpolate(_ start:CGFloat,_ end:CGFloat,_ scalar:CGFloat)->CGFloat{
            return start + (end - start) * scalar
        }
        
        let fromRGBColor:NSColor = self.usingColorSpace(.genericRGB)!
        let toRGBColor:NSColor = to.usingColorSpace(.genericRGB)!
        let red:CGFloat = interpolate(fromRGBColor.redComponent, toRGBColor.redComponent,scalar)
        let green:CGFloat = interpolate(fromRGBColor.greenComponent, toRGBColor.greenComponent,scalar)
        let blue:CGFloat = interpolate(fromRGBColor.blueComponent, toRGBColor.blueComponent,scalar)
        let alpha:CGFloat = interpolate(fromRGBColor.alphaComponent, toRGBColor.alphaComponent,scalar)
        
        return NSColor.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension FloatingPoint {
    
    func clamp(to range: ClosedRange<Self>) -> Self {
        
        if self < range.lowerBound {
            return range.lowerBound
        }
        
        if self > range.upperBound {
            return range.upperBound
        }
        
        return self
    }
}

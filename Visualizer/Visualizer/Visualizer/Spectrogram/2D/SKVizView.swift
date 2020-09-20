import SpriteKit

class SKVizView: SKView, VisualizerViewProtocol {
    
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
    
    var bars: [SKSpriteNode] = []
//    var bars: [SKShapeNode] = []
    
    let tex = SKTexture(size: NSSize(width: 30, height: 250), color1: CIColor(color: NSColor.green)!, color2: CIColor(color: NSColor.red)!)
    
    override func awakeFromNib() {
        
        AppDelegate.play = true
        
        let scene = SKScene(size: self.bounds.size)
        scene.anchorPoint = CGPoint(x: 0, y: 0)
        scene.backgroundColor = NSColor.black
        
//        let tex = SKTexture(size: NSSize(width: 20, height: 250), color1: CIColor(color: NSColor.green)!, color2: CIColor(color: NSColor.red)!)
        
        
        
//        let bar = SKShapeNode(rect: NSRect(x: 20, y: 20, width: 20, height: 250), cornerRadius: 2)
//        bar.fillColor = NSColor.white
//        bar.fillTexture = tex
////        bar.fillTexture = SKTexture(rect: NSRect(x: 0, y: 0, width: tex.size().width, height: 10), in: tex)
//        bar.lineWidth = 0
//
//        print("\nscale=\(bar.yScale)")
//        bar.yScale = 0.3
//
//        print("\nscale=\(bar.yScale)")
//        bar.yScale = 0.8
//
//        print("\nscale=\(bar.yScale)")
//        bar.yScale = 0.6
        
        for i in 0..<10 {
        
            let bar = SKSpriteNode(texture: tex)
            bar.anchorPoint = NSPoint.zero
            bar.position = NSPoint(x: i * 40 + 20, y: 20)
//            let bar = SKShapeNode(rect: NSRect(x: i * 40 + 20, y: 20, width: 30, height: 250), cornerRadius: 3)
//
//            bar.fillColor = NSColor.white
//            bar.fillTexture = tex
//            bar.position.y = 20
//            bar.lineWidth = 0
//
            bars.append(bar)
            scene.addChild(bar)
//
//            let magnitude = CGFloat(i) * 0.1
//            let tex2 = SKTexture(rect: NSRect(x: 0, y: 0, width: 1, height: max(0.001, magnitude)), in: tex)
//            bar.yScale = magnitude
//
//            bar.fillTexture = tex2
//                        bar.position.y = 20
        }
        
//        bar.fillTexture = tex2
//        tex.
        
//        var fr = NSRect(origin: bar.frame.origin, size: NSSize(width: bar.frame.width, height: 100))
//
        presentScene(scene)
    }
    
    func update() {
        
        for i in 0..<10 {
            
            let magnitude = CGFloat(data.magnitudes[i])
            let tex2 = SKTexture(rect: NSRect(x: 0, y: 0, width: 1, height: max(0.001, magnitude)), in: tex)
            
            let action = SKAction.setTexture(tex2, resize: false)
            bars[i].run(action)
//            bars[i].fillTexture = tex2
//            bars[i].fillColor = NSColor.white
//            bars[i].lineWidth = 0
            
//            bars[i].yScale = max(0.001, magnitude)
            
        }
    }
}

extension SKTexture {
    
    convenience init(size:CGSize,color1:CIColor,color2:CIColor) {
        
        let coreImageContext = CIContext(options: nil)
        
        let gradientFilter = CIFilter(name: "CILinearGradient")!
        gradientFilter.setDefaults()
        
        let startVector: CIVector = CIVector(x: size.width/2, y: 0)
        let endVector: CIVector = CIVector(x: size.width/2, y: size.height)
        
        gradientFilter.setValue(startVector, forKey: "inputPoint0")
        gradientFilter.setValue(endVector, forKey: "inputPoint1")
        gradientFilter.setValue(color1, forKey: "inputColor0")
        gradientFilter.setValue(color2, forKey: "inputColor1")
        
        let cgimg = coreImageContext.createCGImage(gradientFilter.outputImage!, from: CGRect(x: 0, y: 0, width: size.width, height: size.height))!
        self.init(cgImage:cgimg)
    }
}

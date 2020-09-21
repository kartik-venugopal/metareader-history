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
    
    static let gradientImage: NSImage = NSImage(named: "Sp-Gradient-Narrow")!
    let gradientTexture = SKTexture(cgImage: SKVizView.gradientImage.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
    
    override func awakeFromNib() {
        
        AppDelegate.play = true
        
        let scene = SKScene(size: self.bounds.size)
        scene.anchorPoint = CGPoint(x: 0, y: 0)
        scene.backgroundColor = NSColor.black
        
        for i in 0..<10 {
        
            let bar = SKSpriteNode(texture: gradientTexture)
            bar.anchorPoint = NSPoint.zero
            bar.position = NSPoint(x: i * 40 + 25, y: 20)
            bar.color = NSColor.green
            bar.blendMode = .replace
            
            bar.size = Self.gradientImage.size
            bars.append(bar)
            scene.addChild(bar)

            bar.texture = nil
            
            print("Scale:", bar.yScale, "Size:", bar.size)
            print("TSize:", bar.texture ?? CGSize.zero, "\n")
        }
        
        presentScene(scene)
    }
    
    func update() {
        
        for i in 0..<10 {

            let magnitude = CGFloat(data.magnitudes[i])
            let bar = bars[i]

            if magnitude <= 0.4 {

                bar.texture = nil
                bar.yScale = magnitude

            } else {

                bar.yScale = 1
                let partialTexture = SKTexture(rect: NSRect(x: 0, y: 0, width: 1, height: max(0.001, magnitude)), in: gradientTexture)
                bar.run(SKAction.setTexture(partialTexture, resize: true))
            }
        }
    }
}

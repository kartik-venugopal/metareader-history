import SpriteKit

class BassBall2D: SKView, VisualizerViewProtocol {
    
    func update(with data: FrequencyData) {
        
        DispatchQueue.main.async {
            self.update()
        }
    }
    
    var ball: SKShapeNode!
    
    override func awakeFromNib() {
        
        let scene = SKScene(size: self.bounds.size)
        scene.anchorPoint = CGPoint(x: 0, y: 0)
        scene.backgroundColor = NSColor.black
        
        self.ball = SKShapeNode(circleOfRadius: 140)
        ball.position = NSPoint(x: 220, y: 160)
        ball.fillColor = NSColor.green
        ball.yScale = 1
        ball.blendMode = .replace
        
        scene.addChild(ball)
        
        presentScene(scene)
    }
    
    var startColor: NSColor = .green
    var endColor: NSColor = .red
    
    func setColors(startColor: NSColor, endColor: NSColor) {
        
        self.startColor = startColor
        self.endColor = endColor
    }
    
    func update() {
        
        let newScale = CGFloat(FrequencyData.fbands[1].maxVal).clamp(to: 0...1)
        
        let newColor = startColor.interpolate(endColor, newScale)
//        let colorAction: SKAction = SKAction.colorize(with: newColor, colorBlendFactor: 1, duration: 0)
        ball.fillColor = newColor
        
        let scaleAction: SKAction = SKAction.scale(to: newScale, duration: 0)
//        let newPos: NSPoint = NSPoint(x: 220 - newRadius, y: 160 - newRadius)
//        let moveAction: SKAction = SKAction.move(to: newPos, duration: 0)
        
//        let sequence = SKAction.sequence([colorAction, scaleAction])
        ball.run(scaleAction)
    }
}

import SpriteKit

class BassBall2D: SKView, VisualizerViewProtocol {
    
    func update(with data: FrequencyData) {
        
        DispatchQueue.main.async {
            self.update()
        }
    }
    
    var ball: SKShapeNode!
    private var gradientImage: NSImage = NSImage(named: "BallTex")!
    private lazy var gradientTexture = SKTexture(image: gradientImage)
    
    override func awakeFromNib() {
        
        let scene = SKScene(size: self.bounds.size)
        scene.anchorPoint = CGPoint(x: 0, y: 0)
        scene.backgroundColor = NSColor.black
        
        self.ball = SKShapeNode(circleOfRadius: 140)
        ball.position = NSPoint(x: 220, y: 160)
        ball.fillColor = NSColor.black
        
        ball.strokeTexture = gradientTexture
        ball.strokeColor = startColor
        ball.lineWidth = 10
        ball.glowWidth = 25
        ball.alpha = 0
        
        ball.yScale = 1
        ball.blendMode = .replace
        ball.isAntialiased = true
        
        scene.addChild(ball)
        presentScene(scene)
        
        ball.run(SKAction.fadeIn(withDuration: 1))
    }
    
    var startColor: NSColor = .green
    var endColor: NSColor = .red
    
    func setColors(startColor: NSColor, endColor: NSColor) {
        
        self.startColor = startColor
        self.endColor = endColor
    }
    
    func update() {
        
        let peakMagnitude = CGFloat(FrequencyData.peakBassMagnitude.clamp(to: 0...1))

        let newColor = startColor.interpolate(endColor, peakMagnitude)
        ball.strokeColor = newColor
        
        ball.run(SKAction.scale(to: peakMagnitude, duration: 0.05))
    }
}

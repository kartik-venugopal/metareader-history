import Cocoa
import AVFoundation

protocol VisualizerViewProtocol {
    
    func update()
    
    func setColors(startColor: NSColor, endColor: NSColor)
    
//    func presentView()
}

class Visualizer: NSObject, PlayerOutputRenderObserver, NSMenuDelegate {
    
    @IBOutlet weak var spectrogram2D: Spectrogram2D!
    @IBOutlet weak var spectrogram3D: Spectrogram3D!
    @IBOutlet weak var supernova: Supernova!
    @IBOutlet weak var discoBall: DiscoBall!
    
    @IBOutlet weak var typeMenu: NSMenu!
    @IBOutlet weak var spectrogram2DMenuItem: NSMenuItem!
    @IBOutlet weak var spectrogram3DMenuItem: NSMenuItem!
    @IBOutlet weak var supernovaMenuItem: NSMenuItem!
    @IBOutlet weak var discoBallMenuItem: NSMenuItem!
    
    @IBOutlet weak var startColorPicker: NSColorWell!
    @IBOutlet weak var endColorPicker: NSColorWell!
    
    var vizView: VisualizerViewProtocol!
    private let fft = FFT.instance
    
    override func awakeFromNib() {
        
        spectrogram2DMenuItem.representedObject = VisualizationType.spectrogram2D
        spectrogram3DMenuItem.representedObject = VisualizationType.spectrogram3D
        supernovaMenuItem.representedObject = VisualizationType.supernova
        discoBallMenuItem.representedObject = VisualizationType.discoBall
    }
    
    @IBAction func changeTypeAction(_ sender: NSPopUpButton) {
        
        if let vizType = sender.selectedItem?.representedObject as? VisualizationType {
            
            switch vizType {
                
            case .spectrogram2D:
                
                vizView = spectrogram2D
                spectrogram2D.show()
                
                spectrogram3D.hide()
                supernova.hide()
                discoBall.hide()
                
            case .spectrogram3D:
                
                vizView = spectrogram3D
                spectrogram3D.show()
                
                spectrogram2D.hide()
                supernova.hide()
                discoBall.hide()
                
            case .supernova:
                
                vizView = supernova
                supernova.show()
                
                spectrogram2D.hide()
                spectrogram3D.hide()
                discoBall.hide()
                
            case .discoBall:
                
                vizView = discoBall
                discoBall.show()
                
                spectrogram2D.hide()
                spectrogram3D.hide()
                supernova.hide()
            }
        }
    }
    
    func performRender(inTimeStamp: AudioTimeStamp, inNumberFrames: UInt32, audioBuffer: AudioBufferList) {
            
        fft.analyze(audioBuffer)

        DispatchQueue.main.async {
            self.vizView?.update()
        }
    }
    
    @IBAction func setColorsAction(_ sender: NSColorWell) {
        
        [spectrogram2D, spectrogram3D, supernova, discoBall].forEach {
            
            ($0 as? VisualizerViewProtocol)?.setColors(startColor: self.startColorPicker.color, endColor: self.endColorPicker.color)
        }
    }
}

enum VisualizationType {
    
    case spectrogram2D, spectrogram3D, supernova, discoBall
}

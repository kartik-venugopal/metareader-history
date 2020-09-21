import Cocoa
import AVFoundation

protocol VisualizerViewProtocol {
    
    func update(with data: FrequencyData)
    
    func setColors(startColor: NSColor, endColor: NSColor)
}

class Visualizer: NSObject, PlayerOutputRenderObserver, NSMenuDelegate {
    
    @IBOutlet weak var spectrogram2D: SKVizView!
    @IBOutlet weak var spectrogram3D: SCNVizView!
    
    @IBOutlet weak var typeMenu: NSMenu!
    @IBOutlet weak var spectrogram2DMenuItem: NSMenuItem!
    @IBOutlet weak var spectrogram3DMenuItem: NSMenuItem!
    
    @IBOutlet weak var startColorPicker: NSColorWell!
    @IBOutlet weak var endColorPicker: NSColorWell!
    
    var vizView: VisualizerViewProtocol!
    private let fft = FFT.instance
    
    override func awakeFromNib() {
        
        vizView = spectrogram2D
        
        spectrogram2D.show()
        spectrogram3D.hide()
        
        spectrogram2DMenuItem.representedObject = VisualizationType.spectrogram2D
        spectrogram3DMenuItem.representedObject = VisualizationType.spectrogram3D
    }
    
    @IBAction func changeTypeAction(_ sender: NSPopUpButton) {
        
        if let vizType = sender.selectedItem?.representedObject as? VisualizationType {
            
            switch vizType {
                
            case .spectrogram2D:
                
                vizView = spectrogram2D

                spectrogram2D.show()
                spectrogram3D.hide()
                
            case .spectrogram3D:
                
                vizView = spectrogram3D
                
                spectrogram2D.hide()
                spectrogram3D.show()
                
            default:
                
                vizView = spectrogram2D
                
                spectrogram2D.show()
                spectrogram3D.hide()
            }
        }
    }
    
    private var ctr: Int = 0
    
    func performRender(inTimeStamp: AudioTimeStamp, inNumberFrames: UInt32, audioBuffer: AudioBufferList) {
        
        ctr += 1
        
        if ctr % 4 == 0 {
            
            let data = fft.analyze(audioBuffer)
            vizView.update(with: data)
        }
    }
    
    @IBAction func setColorsAction(_ sender: NSColorWell) {
        
        [spectrogram2D, spectrogram3D].forEach {
            
            ($0 as? VisualizerViewProtocol)?.setColors(startColor: self.startColorPicker.color, endColor: self.endColorPicker.color)
        }
    }
}

enum VisualizationType {
    
    case spectrogram2D, spectrogram3D, bassBall2D
}

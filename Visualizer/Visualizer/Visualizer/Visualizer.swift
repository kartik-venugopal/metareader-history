import Cocoa
import AVFoundation

protocol VisualizerViewProtocol {
    
    func update(with data: FrequencyData)
    
    func update()
    
    func setColors(startColor: NSColor, endColor: NSColor)
}

class Visualizer: NSObject, PlayerOutputRenderObserver, NSMenuDelegate {
    
    @IBOutlet weak var spectrogram2D: Spectrogram2D!
    @IBOutlet weak var spectrogram3D: Spectrogram3D!
    
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
    
    var cnt: Int = 0
    var tm: Double = 0
    
    func performRender(inTimeStamp: AudioTimeStamp, inNumberFrames: UInt32, audioBuffer: AudioBufferList) {
            
        var st = CFAbsoluteTimeGetCurrent()
        fft.analyze(audioBuffer)
        var end = CFAbsoluteTimeGetCurrent()
        
        var time = (end - st) * 1000
        tm += time
        cnt += 1
        
        if cnt == 500 {
            
            let avg = tm / 500.0
            print("\nAvg FFT time: \(avg)")
        }
        
        vizView.update()
        
//        vizView.update(with: data)
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

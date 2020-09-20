import Cocoa
import AVFoundation

protocol VisualizerViewProtocol {
    
    func update(with data: FrequencyData)
}

class Visualizer: PlayerOutputRenderObserver {
    
    var sp: VisualizerViewProtocol!
    private let fft = FFT.instance
    
    init(sp: VisualizerViewProtocol) {
        self.sp = sp
    }
    
    var ctr: Int = 0
    
    func performRender(inTimeStamp: AudioTimeStamp, inNumberFrames: UInt32, audioBuffer: AudioBufferList) {
        
        ctr += 1
        
        //                let cap = Int(buf.mBuffers.mDataByteSize) / MemoryLayout<Float>.size / Int(buf.mBuffers.mNumberChannels)
        //                NSLog("HOLY SHIT !!! BufSize: \(cap)")
        
        if ctr % 4 == 0 {
            
            let data = fft.fft2(audioBuffer)
            sp.update(with: data)
        }
    }
}

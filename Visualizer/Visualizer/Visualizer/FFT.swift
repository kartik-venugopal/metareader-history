import Foundation
import Accelerate
import AVFoundation

class FFT {
    
    let frameCount: Int = 1024
    var sampleRate: Float
    
    var log2n: UInt
    let bufferSizePOT: Int
    let halfBufferSize: Int
    let fftSetup: FFTSetup
    
    var realp: [Float]
    var imagp: [Float]
    var output: DSPSplitComplex
    let windowSize: Int
    
    var transferBuffer: [Float]
    var window: [Float]
    
    var magnitudes: [Float]
    var normalizedMagnitudes: [Float]
    
    static let instance: FFT = FFT(sampleRate: 44100)
    
    private init(sampleRate: Float) {
        
        self.sampleRate = sampleRate
        
        log2n = UInt(round(log2(Double(frameCount))))
        bufferSizePOT = Int(1 << log2n)
        halfBufferSize = bufferSizePOT / 2
        
        //        print("half", halfBufferSize, frameCount)
        
        fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))!
        
        realp = [Float](repeating: 0, count: halfBufferSize)
        imagp = [Float](repeating: 0, count: halfBufferSize)
        output = DSPSplitComplex(realp: &realp, imagp: &imagp)
        windowSize = bufferSizePOT
        
        transferBuffer = [Float](repeating: 0, count: windowSize)
        window = [Float](repeating: 0, count: windowSize)
        
        magnitudes = [Float](repeating: 0, count: halfBufferSize)
        normalizedMagnitudes = [Float](repeating: 0, count: halfBufferSize)
    }
    
    func sqrtq(_ x: [Float]) -> [Float] {
        
        var results = [Float](repeating: 0, count: x.count)
        vvsqrtf(&results, x, [Int32(x.count)])
        
        return results
    }
    
    func analyze(_ buffer: AudioBufferList) -> FrequencyData {
        
        let pptr: UnsafeMutablePointer<Float> = buffer.mBuffers.mData!.bindMemory(to: Float.self, capacity: Int(buffer.mBuffers.mNumberChannels))
        let ptr: UnsafePointer<Float> = UnsafePointer(pptr)
        
        // Hann windowing to reduce the frequency leakage
        vDSP_hann_window(&window, vDSP_Length(windowSize), Int32(vDSP_HANN_NORM))
        vDSP_vmul(ptr, 1, window,
                  1, &transferBuffer, 1, vDSP_Length(windowSize))
        
        ptr.withMemoryRebound(to: DSPComplex.self, capacity: bufferSizePOT / 2) {dspComplexStream in
            vDSP_ctoz(dspComplexStream, 2, &output, 1, UInt(bufferSizePOT / 2))
        }
        
        // Perform the FFT
        vDSP_fft_zrip(fftSetup, &output, 1, log2n, FFTDirection(FFT_FORWARD))
        
        vDSP_zvmags(&output, 1, &magnitudes, 1, vDSP_Length(halfBufferSize))
        
        // Normalizing
        vDSP_vsmul(self.sqrtq(magnitudes), 1, [2.0 / Float(halfBufferSize)],
                   &normalizedMagnitudes, 1, vDSP_Length(halfBufferSize))
        
        //        vDSP_destroy_fftsetup(fftSetup)
        
        var freqs = [Float](repeating: 0, count: halfBufferSize)
        var mags = [Float](repeating: 0, count: halfBufferSize)
        
        let frameCount_f = Float(frameCount)
        
        //        print("\nNM has " + String(normalizedMagnitudes.count))
        
        for i in 0...(normalizedMagnitudes.count) - 1 {
            
            freqs[i] = Float(i) * sampleRate / frameCount_f
            mags[i] = normalizedMagnitudes[i]
        }
        
        let data = FrequencyData(sampleRate: sampleRate, frequencies: freqs, magnitudes: mags)
        
        return data
    }
}


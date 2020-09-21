import Foundation
import Accelerate
import AVFoundation

class FFT {
    
    static let instance: FFT = FFT()
    
    private init() {}
    
    var fftSetup: FFTSetup!
    
    var log2n: UInt = 9
    var bufferSizePOT: Int = 512
    var bufferSizePOT_Float: Float = 512
    var halfBufferSize: Int = 256
    var halfBufferSize_Int32: Int32 = 256
    var halfBufferSize_UInt: UInt = 256
    var halfBufferSize_Float: Float = 256
    var vsMulScalar: [Float] = [2.0 / 256]
    var vvsqrtf_numElements: [Int32] = [256]
    
    var realp: [Float] = []
    var imagp: [Float] = []
    var output: DSPSplitComplex!
    var windowSize: Int = 512
    var windowSize_vDSPLength: vDSP_Length = 512
    
    let fftRadix: Int32 = Int32(kFFTRadix2)
    let vDSP_HANN_NORM_Int32: Int32 = Int32(vDSP_HANN_NORM)
    let fftDirection: FFTDirection = FFTDirection(FFT_FORWARD)
    
    var transferBuffer: [Float] = []
    var window: [Float] = []
    
    var frequencies: [Float] = []
    var magnitudes: [Float] = []
    var squareRoots: [Float] = []
    var normalizedMagnitudes: [Float] = []
    
    var sampleRate: Float = 44100 {
        
        didSet {
            frequencies = (0..<halfBufferSize).map {Float($0) * self.sampleRate / self.bufferSizePOT_Float}
        }
    }
    
    var bufferSize: Int = 512 {
        
        didSet {
            
            log2n = UInt(round(log2(Double(bufferSize))))
            bufferSizePOT = Int(1 << log2n)
            
            halfBufferSize = bufferSizePOT / 2
            halfBufferSize_Int32 = Int32(halfBufferSize)
            halfBufferSize_UInt = UInt(halfBufferSize)
            halfBufferSize_Float = Float(halfBufferSize)
            
            //        print("half", halfBufferSize, frameCount)
            
            fftSetup = vDSP_create_fftsetup(log2n, fftRadix)!
            
            realp = [Float](repeating: 0, count: halfBufferSize)
            imagp = [Float](repeating: 0, count: halfBufferSize)
            output = DSPSplitComplex(realp: &realp, imagp: &imagp)
            
            windowSize = bufferSizePOT
            windowSize_vDSPLength = vDSP_Length(windowSize)
            
            transferBuffer = [Float](repeating: 0, count: windowSize)
            window = [Float](repeating: 0, count: windowSize)
            
            frequencies = (0..<halfBufferSize).map {Float($0) * self.sampleRate / self.bufferSizePOT_Float}
            magnitudes = [Float](repeating: 0, count: halfBufferSize)
            squareRoots = [Float](repeating: 0, count: halfBufferSize)
            normalizedMagnitudes = [Float](repeating: 0, count: halfBufferSize)
            
            vsMulScalar = [2.0 / halfBufferSize_Float]
            vvsqrtf_numElements = [halfBufferSize_Int32]
        }
    }
    
    func analyze(_ buffer: AudioBufferList) -> FrequencyData {
        
        let bufferPtr: UnsafePointer<Float> = UnsafePointer(buffer.mBuffers.mData!.bindMemory(to: Float.self, capacity: Int(buffer.mBuffers.mNumberChannels)))
        
        // Hann windowing to reduce the frequency leakage
        vDSP_hann_window(&window, windowSize_vDSPLength, vDSP_HANN_NORM_Int32)
        vDSP_vmul(bufferPtr, 1, window, 1, &transferBuffer, 1, windowSize_vDSPLength)
        
        bufferPtr.withMemoryRebound(to: DSPComplex.self, capacity: halfBufferSize) {dspComplexStream in
            vDSP_ctoz(dspComplexStream, 2, &output, 1, halfBufferSize_UInt)
        }
        
        // Perform the FFT
        vDSP_fft_zrip(fftSetup, &output, 1, log2n, fftDirection)
        vDSP_zvmags(&output, 1, &magnitudes, 1, halfBufferSize_UInt)
        
        // Normalizing
        vvsqrtf(&squareRoots, magnitudes, vvsqrtf_numElements)
        vDSP_vsmul(squareRoots, 1, vsMulScalar, &normalizedMagnitudes, 1, halfBufferSize_UInt)
        
        return FrequencyData(sampleRate: sampleRate, frequencies: frequencies, magnitudes: normalizedMagnitudes)
    }
    
    deinit {
        
        if fftSetup != nil {
            vDSP_destroy_fftsetup(fftSetup)
        }
    }
}

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
    
    var transferBuffer: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>.allocate(capacity: 0)
    var window: [Float] = []
    var windowSize: Int = 512
    var windowSize_vDSPLength: vDSP_Length = 512
    
    let fftRadix: Int32 = Int32(kFFTRadix2)
    let vDSP_HANN_NORM_Int32: Int32 = Int32(vDSP_HANN_NORM)
    let fftDirection: FFTDirection = FFTDirection(FFT_FORWARD)
    var zeroDBReference: Float = 1
    
    var frequencies: [Float] = []
    var magnitudes: [Float] = []
    var squareRoots: [Float] = []
//    var normalizedMagnitudes: [Float] = []
    var normalizedMagnitudes: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>.allocate(capacity: 0)
    
    var sampleRate: Float = 44100 {

        didSet {
            frequencies = (0..<halfBufferSize).map {Float($0) * self.nyquistFrequency / self.halfBufferSize_Float}
            NSLog("*** SET SR TO \(sampleRate)\n")
        }
    }
    
    var nyquistFrequency: Float {
        sampleRate / 2
    }
    
    var bufferSize: Int = 512 {
        
        didSet {
            
            log2n = UInt(round(log2(Double(bufferSize))))
            
            bufferSizePOT = Int(1 << log2n)
            bufferSizePOT_Float = Float(bufferSizePOT)
            
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
            
//            transferBuffer = [Float](repeating: 0, count: windowSize)
            transferBuffer = UnsafeMutablePointer<Float>.allocate(capacity: windowSize)
            window = [Float](repeating: 0, count: windowSize)
            
            frequencies = (0..<halfBufferSize).map {Float($0) * self.nyquistFrequency / self.halfBufferSize_Float}
            magnitudes = [Float](repeating: 0, count: halfBufferSize)
            squareRoots = [Float](repeating: 0, count: halfBufferSize)
//            normalizedMagnitudes = [Float](repeating: 0, count: halfBufferSize)
            normalizedMagnitudes = UnsafeMutablePointer<Float>.allocate(capacity: halfBufferSize)
            
//            vsMulScalar = [2.0 / halfBufferSize_Float]
            vsMulScalar = [Float(1.0) / Float(128.0)]
            vvsqrtf_numElements = [halfBufferSize_Int32]
        }
    }
    
    var cnt: Int = 0
    var tm: Double = 0
    
    func analyze(_ buffer: AudioBufferList) {
        
        let bufferPtr: UnsafePointer<Float> = UnsafePointer(buffer.mBuffers.mData!.assumingMemoryBound(to: Float.self))
        
        // Hann windowing to reduce the frequency leakage
        vDSP_hann_window(&window, windowSize_vDSPLength, vDSP_HANN_NORM_Int32)
        vDSP_vmul(bufferPtr, 1, window, 1, transferBuffer, 1, windowSize_vDSPLength)
        
        transferBuffer.withMemoryRebound(to: DSPComplex.self, capacity: windowSize) {dspComplexStream in
            vDSP_ctoz(dspComplexStream, 2, &output, 1, halfBufferSize_UInt)
        }
        
        // Perform the FFT
        vDSP_fft_zrip(fftSetup, &output, 1, log2n, fftDirection)
        
        // Convert FFT output to magnitudes
        vDSP_zvmags(&output, 1, &magnitudes, 1, halfBufferSize_UInt)
        
        vDSP_vdbcon(&magnitudes, 1, &zeroDBReference, normalizedMagnitudes, 1, halfBufferSize_UInt, 1)
        vDSP_vsmul(normalizedMagnitudes, 1, vsMulScalar, normalizedMagnitudes, 1, halfBufferSize_UInt)
        
        let st = CFAbsoluteTimeGetCurrent()
//        FrequencyData.update(frequencies: frequencies, magnitudes: normalizedMagnitudes)
        
        for band in FrequencyData.fbands {
//            var val: Float = 0
//            vDSP_maxv(normalizedMagnitudes.advanced(by: band.minIndex), 1, &val, band.indexCount)
            vDSP_maxv(normalizedMagnitudes.advanced(by: band.minIndex), 1, &band.maxVal, band.indexCount)
        }
        
        let end = CFAbsoluteTimeGetCurrent()
        
        let time = (end - st) * 1000
        tm += time
        cnt += 1
        
        if cnt == 500 {
            
            let avg = tm / 500.0
            print("\nAvg FData() time: \(avg)")
        }
        
//        return data
    }
    
    deinit {
        
        if fftSetup != nil {
            vDSP_destroy_fftsetup(fftSetup)
        }
    }
}

extension Array where Element: FloatingPoint {
    
    func fastMin() -> Float {
        
        let floats = self as! [Float]
        var min: Float = 0
        vDSP_minv(floats, 1, &min, UInt(count))
        return min
    }
    
    func fastMax() -> Float {
        
        let floats = self as! [Float]
        var max: Float = 0
        vDSP_maxv(floats, 1, &max, UInt(count))
        return max
    }
    
    func avg() -> Float {
        
        let floats = self as! [Float]
        var mean: Float = 0
        vDSP_meanv(floats, 1, &mean, UInt(count))
        return mean
    }
}

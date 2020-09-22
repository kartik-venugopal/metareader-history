import Cocoa

class FrequencyData {
    
    var sampleRate: Float
    var frequencies: [Float]
    var magnitudes: [Float]
    
    var bands: [Band]
    
    static let powers: [Int: Float] = [5: 32, 6: 64, 7: 128, 8: 256, 9: 512, 10: 1024, 11: 2048, 12: 4096, 13: 8192, 14: 16384]
    static let indexRanges: [ClosedRange<Int>] = []
    
    init(sampleRate: Float, frequencies: [Float], magnitudes: [Float]) {
        
        self.sampleRate = sampleRate
        self.frequencies = frequencies
        self.magnitudes = magnitudes

        let firstFreq = frequencies[1]
        self.bands = []
        
        var maxMag: Float = -10000
//        var magSum: Float = 0
        
//        print("\n *** MAXF: \(frequencies.last!)")

        for power in 5...14 {
            
            let twoPowerBandwidth = powf(2, 1)
            let centerFreq = Self.powers[power]!
            
            let minF = sqrt((centerFreq * centerFreq) / twoPowerBandwidth)
            let maxF = minF * twoPowerBandwidth

            let minI = Int(round(minF / firstFreq))
            let maxI = min(magnitudes.count - 1, Int(round(maxF / firstFreq)) - 1)
            
//            print("\nFor band with cfreq \(centerFreq), minI = \(minI), maxI = \(maxI)")
            
            let band = Band(minF: minF, maxF: maxF, minIndex: minI, maxIndex: maxI)
            bands.append(band)
            
            maxMag = -10000
//            magSum = 0
            
            for magIndex in minI...maxI {
                
                if magnitudes[magIndex] > maxMag {
                    maxMag = magnitudes[magIndex]
                }
                
//                magSum += magnitudes[magIndex]
            }
            
//            band.avgVal = magSum / Float(band.maxIndex - band.minIndex + 1)
            band.maxVal = maxMag
        }
        
//        DispatchQueue.global(qos: .utility).async {
//
//            self.bands.forEach {print($0.toString())}
//            print("\n-----------------------------------\n")
//        }
    }
    
    func findMaxAndAverageForFrequencies(_ minI: Int, maxI: Int) -> (max: Float, avg: Float) {
        
        var max = 0 - Float.infinity
        var sum: Float = 0
        
        for i in minI...maxI {
            
            if (magnitudes[i]) > max {
                max = magnitudes[i]
            }
            
            sum += magnitudes[i]
        }
        
        return (max, sum / Float(maxI - minI + 1))
    }
}

class Band {
    
    var minF: Float
    var maxF: Float
    
    var minIndex: Int
    var maxIndex: Int
    
    var avgVal: Float = 0
    var maxVal: Float = 0
    
    init(minF: Float, maxF: Float, minIndex: Int, maxIndex: Int) {
        
        self.minF = minF
        self.maxF = maxF
        
        self.minIndex = minIndex
        self.maxIndex = maxIndex
        
//        print("\nFor center F \(centerFreq), min = \(minF), max = \(maxF)")
    }
    
    func toString() -> String {
        return "minF: \(minF), maxF: \(maxF), avg: \(avgVal), max: \(maxVal)"
    }
}


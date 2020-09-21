import Cocoa

class FrequencyData {
    
    var sampleRate: Float
    var frequencies: [Float]
    var magnitudes: [Float]
    
//    var bands: [Band]
    
    static var powers: [Int: Int] = [5: 32, 6: 64, 7: 128, 8: 256, 9: 512, 10: 1024, 11: 2048, 12: 4096, 13: 8192, 14: 16384]
    
    init(sampleRate: Float, frequencies: [Float], magnitudes: [Float]) {
        
        self.sampleRate = sampleRate
        self.frequencies = frequencies
        self.magnitudes = magnitudes
        
//        var map: [Float: Float] = [:]
//        var tuples: [(F: Float, M: Float)] = []
//        
//        for (freq, mag) in zip(frequencies, magnitudes).sorted(by: {$0.0 < $1.0}) {
//            map[freq] = mag
//        }
//        
//        for f in frequencies {
//            print("\(f): \(map[f]!)")
//        }
//        
//        print("\n------------------------\n")
        
//        print("\nFreqs: \(map)")
        
//        var minF = 0
//        let firstFreq = frequencies[1]
//        self.bands = []
//
//        for power in 5...14 {
//
//            let maxF = Self.powers[power]!
//
//            let band = Band(minF: minF, maxF: maxF)
//            bands.append(band)
//
//            let minI = Int(round(Float(minF) / firstFreq))
//            let maxI = Int(round(Float(maxF) / firstFreq))
//
//            let maxAvg = findMaxAndAverageForFrequencies(minI, maxI: maxI)
//            band.maxVal = maxAvg.max
//            band.avgVal = maxAvg.avg
//
//            minF = maxF
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
    
    var minF: Int
    var maxF: Int
    
    var avgVal: Float = 0
    var maxVal: Float = 0
    
    init(minF: Int, maxF: Int) {
        
        self.minF = minF
        self.maxF = maxF
    }
}


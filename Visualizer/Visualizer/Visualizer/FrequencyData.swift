import Cocoa

struct BandFRange {
    
    let minF: Float
    let maxF: Float
    
    let minIndex: Int
    let maxIndex: Int
}

class FrequencyData {
    
    static let fbands: [Band] = {
        
        /*
         bands.append(Band(minF: 22.627417, maxF: 45.254833, minIndex: 1, maxIndex: 1)
         bands.append(Band(minF: 45.254833, maxF: 90.50967, minIndex: 2, maxIndex: 3)
         bands.append(Band(minF: 90.50967, maxF: 181.01933, minIndex: 4, maxIndex: 7)
         bands.append(Band(minF: 181.01933, maxF: 362.03867, minIndex: 8, maxIndex: 14)
         bands.append(Band(minF: 362.03867, maxF: 724.07733, minIndex: 15, maxIndex: 30)
         bands.append(Band(minF: 724.07733, maxF: 1448.1547, minIndex: 31, maxIndex: 61)
         bands.append(Band(minF: 1448.1547, maxF: 2896.3093, minIndex: 62, maxIndex: 123)
         bands.append(Band(minF: 2896.3093, maxF: 5792.6187, minIndex: 124, maxIndex: 246)
         bands.append(Band(minF: 5792.6187, maxF: 11585.237, minIndex: 247, maxIndex: 493)
         bands.append(Band(minF: 11585.237, maxF: 23170.475, minIndex: 494, maxIndex: 988)
         */

        var bands: [Band] = []

        bands.append(Band(minF: 22.627417, maxF: 45.254833, minIndex: 1, maxIndex: 1))
        bands.append(Band(minF: 45.254833, maxF: 90.50967, minIndex: 2, maxIndex: 3))
        bands.append(Band(minF: 90.50967, maxF: 181.01933, minIndex: 4, maxIndex: 7))
        bands.append(Band(minF: 181.01933, maxF: 362.03867, minIndex: 8, maxIndex: 14))
        bands.append(Band(minF: 362.03867, maxF: 724.07733, minIndex: 15, maxIndex: 30))
        bands.append(Band(minF: 724.07733, maxF: 1448.1547, minIndex: 31, maxIndex: 61))
        bands.append(Band(minF: 1448.1547, maxF: 2896.3093, minIndex: 62, maxIndex: 123))
        bands.append(Band(minF: 2896.3093, maxF: 5792.6187, minIndex: 124, maxIndex: 246))
        bands.append(Band(minF: 5792.6187, maxF: 11585.237, minIndex: 247, maxIndex: 493))
        bands.append(Band(minF: 11585.237, maxF: 23170.475, minIndex: 494, maxIndex: 988))

        return bands
    }()
    
    static var bands: [Band] = []
    static var frequencies: [Float] = []
    static var magnitudes: [Float] = []
    
    static let powers: [Int: Float] = [5: 32, 6: 64, 7: 128, 8: 256, 9: 512, 10: 1024, 11: 2048, 12: 4096, 13: 8192, 14: 16384]
    static let indexRanges: [ClosedRange<Int>] = []
    
    static func update(frequencies: [Float], magnitudes: [Float]) {
        
        self.frequencies = frequencies
        self.magnitudes = magnitudes

        let firstFreq = frequencies[1]
        self.bands = []
        
        var maxMag: Float = -10000
//        var magSum: Float = 0
        
//        print("\n *** MAXF: \(frequencies.last!)")

        for power in 5...14 {
            
//            let twoPowerBandwidth = powf(2, 1)
            let centerFreq = Self.powers[power]!
            
            let minF = sqrt((centerFreq * centerFreq) / 2)
            let maxF = minF * 2

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
    
//    func findMaxAndAverageForFrequencies(_ minI: Int, maxI: Int) -> (max: Float, avg: Float) {
//
//        var max = 0 - Float.infinity
//        var sum: Float = 0
//
//        for i in minI...maxI {
//
//            if (magnitudes[i]) > max {
//                max = magnitudes[i]
//            }
//
//            sum += magnitudes[i]
//        }
//
//        return (max, sum / Float(maxI - minI + 1))
//    }
}

class Band {
    
    let minF: Float
    let maxF: Float
    
    let minIndex: Int
    let maxIndex: Int
    
    var avgVal: Float = 0
    var maxVal: Float = 0
    
    init(minF: Float, maxF: Float, minIndex: Int, maxIndex: Int) {
        
        self.minF = minF
        self.maxF = maxF
        
        self.minIndex = minIndex
        self.maxIndex = maxIndex
        
//        print("\nFor center F \(centerFreq), min = \(minF), max = \(maxF)")
//        print(toString())
    }
    
    func toString() -> String {
        return "minF: \(minF), maxF: \(maxF), minIndex: \(minIndex), maxIndex: \(maxIndex), avg: \(avgVal), max: \(maxVal)"
    }
}


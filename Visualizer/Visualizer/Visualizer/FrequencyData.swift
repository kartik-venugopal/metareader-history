import Cocoa

struct BandFRange {
    
    let minF: Float
    let maxF: Float
    
    let minIndex: Int
    let maxIndex: Int
}

class FrequencyData {
    
    static let fbands: [Band] = {

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
    
    static var peakBassMagnitude: Float = 0
    
    static var bands: [Band] = []
    
//    static let powers: [Int: Float] = [5: 32, 6: 64, 7: 128, 8: 256, 9: 512, 10: 1024, 11: 2048, 12: 4096, 13: 8192, 14: 16384]
//    static let indexRanges: [ClosedRange<Int>] = []
}

class Band {
    
    let minF: Float
    let maxF: Float
    
    let minIndex: Int
    let maxIndex: Int
    let indexCount: UInt
    
    var avgVal: Float = 0
    var maxVal: Float = 0
    
    init(minF: Float, maxF: Float, minIndex: Int, maxIndex: Int) {
        
        self.minF = minF
        self.maxF = maxF
        
        self.minIndex = minIndex
        self.maxIndex = maxIndex
        self.indexCount = UInt(maxIndex - minIndex + 1)
        
//        print("\nFor center F \(centerFreq), min = \(minF), max = \(maxF)")
//        print(toString())
    }
    
    func toString() -> String {
        return "minF: \(minF), maxF: \(maxF), minIndex: \(minIndex), maxIndex: \(maxIndex), avg: \(avgVal), max: \(maxVal)"
    }
}


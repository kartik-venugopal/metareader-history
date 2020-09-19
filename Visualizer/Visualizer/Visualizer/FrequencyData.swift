import Cocoa

class FrequencyData {
    
    var sampleRate: Float
    var frequencies: [Float]
    var magnitudes: [Float]
    
    var bands: [Band]
    
    init(sampleRate: Float, frequencies: [Float], magnitudes: [Float]) {
        
        self.sampleRate = sampleRate
        self.frequencies = frequencies
        self.magnitudes = magnitudes
        
        var minF = 0
        let firstFreq = frequencies[1]
        self.bands = [Band]()
        
        for power in 5...14 {
            
            let maxF = Int(pow(Double(2), Double(power)))
            
            let band = Band(minF: minF, maxF: maxF)
            bands.append(band)
            
            let minI = Int(round(Float(minF) / firstFreq))
            let maxI = Int(round(Float(maxF) / firstFreq))
            
            let maxAvg = findMaxAndAverageForFrequencies(minI, maxI: maxI)
            band.maxVal = maxAvg.max
            band.avgVal = maxAvg.avg
            
            minF = maxF
        }
    }
    
    func findMagnitudeForFrequency(_ freq: Int) -> Float {
        
        // TODO: Use interpolation
        
        let firstFreq = frequencies[1]
        
        let index = Int(round(Float(freq) / firstFreq))
        
        //        Swift.print("forFreq:", freq, index, frequencies[index], magnitudes[index])
        
        return magnitudes[index]
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


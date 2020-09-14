import AVFoundation

class ParserUtils {
    
    static func getID3Genre(_ item: AVMetadataItem, _ offset: Int = 0) -> String? {
        
        if let num = item.numberValue {
            return GenreMap.forID3Code(num.intValue + offset)
        }
        
        if let str = item.stringValue {
            return parseID3GenreNumericString(str, offset)
        }
        
        if let data = item.dataValue {
            
            if let dataType = item.dataType, dataType as NSString == kCMMetadataBaseDataType_RawData as NSString {
                
                let vals = data.filter({num -> Bool in num > 0})
                
                if let firstVal = vals.first {
                    return GenreMap.forID3Code(Int(firstVal) + offset)
                }
                
            } else if let dataType = item.dataType, dataType as NSString == kCMMetadataBaseDataType_UTF8 as NSString {
                
                return String(data: data, encoding: .utf8)
                
            } else {
                
                let vals = data.filter({num -> Bool in num > 0})
                
                if vals.count > 1 {
                    // Probably a string
                    return String(data: data, encoding: .utf8)
                    
                } else if vals.count == 1, let firstVal = vals.first {

                    return GenreMap.forID3Code(Int(firstVal) + offset)
                }
            }
        }
        
        return nil
    }
    
    static func parseID3GenreNumericString(_ string: String, _ offset: Int = 0) -> String {
        
        if let genreCode = parseNumericString(string) {
            // Look up genreId in ID3 table
            return GenreMap.forID3Code(genreCode + offset) ?? string
        }
        
        return string
    }
    
    static func parseNumericString(_ string: String) -> Int? {
        
        let decimalChars = CharacterSet.decimalDigits
        let alphaChars = CharacterSet.lowercaseLetters.union(CharacterSet.uppercaseLetters)
        
        // If no alphabetic characters are present, and numeric characters are present, treat this as a numerical genre code
        if string.rangeOfCharacter(from: alphaChars) == nil, string.rangeOfCharacter(from: decimalChars) != nil {
            
            // Need to parse the number
            let numberStr = string.trimmingCharacters(in: decimalChars.inverted)
            if let number = Int(numberStr) {
                return number
            }
        }
        
        return nil
    }
    
    static func parseDiscOrTrackNumber(_ item: AVMetadataItem) -> (number: Int?, total: Int?)? {
        
        if let number = item.numberValue {
            return (number.intValue, nil)
        }
        
        if let stringValue = item.stringValue?.trim() {
            
            // Parse string (e.g. "2 / 13")
            
           return parseDiscOrTrackNumberString(stringValue)

        } else if let dataValue = item.dataValue {
            
            let vals = dataValue.filter({num -> Bool in num > 0})
            
            switch vals.count {
                
            case 0: return (nil, nil)
                
            case 1: return (Int(vals[0]), nil)
                
            default: return (Int(vals[0]), Int(vals[1]))
                
            }
        }
        
        return nil
    }
    
    static func parseDiscOrTrackNumberString(_ stringValue: String) -> (number: Int?, total: Int?)? {
        
        // Parse string (e.g. "2 / 13")
        
        if let num = Int(stringValue) {
            return (num, nil)
        }
        
        let tokens = stringValue.split(separator: "/")
        
        switch tokens.count {
            
        case 0: return (nil, nil)
            
        case 1: return (Int(tokens[0].trim()), nil)
            
        default:    return (Int(tokens[0].trim()), Int(tokens[1].trim()))
            
        }
    }
    
    static let validYearRange: ClosedRange<Int> = 1000...3000
    static let centuryYearRange: ClosedRange<Int> = 0...99

    static func parseYear(_ item: AVMetadataItem) -> Int? {
        
        if let number = item.numberValue, validYearRange.contains(number.intValue) {
            return number.intValue
        }
        
        if let stringValue = item.stringValue?.trim() {
            
            return parseYear(stringValue)

        } else if let dataValue = item.dataValue {
            
            let vals = dataValue.filter({num -> Bool in num > 0})
            
            switch vals.count {
                
            case 0:
                
                return nil
                
            default:
                
                let year: Int = Int(vals[0])
                return validYearRange.contains(year) ? year : nil
            }
        }
        
        return nil
    }
    
    static let mmddyyRegex: String = "[0-9]+-[0-9]+-[0-9]+"
    
    static func parseYear(_ yearString: String) -> Int? {
        
        if let year = Int(yearString), validYearRange.contains(year) {
            return year
        }
        
        if yearString.matches(mmddyyRegex) {
            
            let tokens = yearString.split(separator: "-")
            if tokens.count == 3, let year = Int(tokens[2]) {
                
                switch year {
                    
                case validYearRange:
                    
                    return year
                    
                case centuryYearRange:
                    
                    let currentCenturyYear = Calendar.current.component(.year, from: Date()) % 100
                    return year < currentCenturyYear ? (2000 + year) : (1900 + year)
                    
                default:
                    
                    return nil
                }
            }
        }
        
        return nil
    }
    
    static func parseBPM(_ item: AVMetadataItem) -> Int? {
        
        if let number = item.numberValue, number.intValue > 0 {
            return number.intValue
        }
        
        if let stringValue = item.stringValue?.trim() {
            
            return parseBPM(stringValue)

        } else if let dataValue = item.dataValue {
            
            let vals = dataValue.filter {$0 > 0}
            
            switch vals.count {
                
            case 0:
                
                return nil
                
            default:
                
                let bpm: Int = Int(vals[0])
                return bpm > 0 ? bpm : nil
            }
        }
        
        return nil
    }
    
    static func parseBPM(_ bpmString: String) -> Int? {
        
        if let bpm = Int(bpmString), bpm > 0 {
            return bpm
        }
        
        return nil
    }
    
    static let hmsRegex = "[0-9]+:[0-9]+:[0-9]+[\\.]?[0-9]*"
    
    static func parseDuration(_ durString: String) -> Double? {
        
        if let durationMsecs = Int64(durString) {
            return Double(durationMsecs) / 1000.0
        }
        
        if let durationSecs = Double(durString) {
            return durationSecs
        }
        
        if durString.matches(hmsRegex) {
            
            let tokens = durString.split(separator: ":")
            if tokens.count == 3, let hours = Double(tokens[0]), let mins = Double(tokens[1]), let secs = Double(tokens[2]) {
                return (hours * 3600) + (mins * 60) + secs
            }
        }
        
        return nil
    }
    
//    static func getImageMetadata(_ image: NSData) -> ImageMetadata? {
//        
//        if let imageSourceRef = CGImageSourceCreateWithData(image, nil), let currentProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, nil) {
//        
//            let dict = NSMutableDictionary(dictionary: currentProperties)
//            
//            let imgMetadata = ImageMetadata()
//            
//            if let colorModel = dict["ColorModel"] as? String {
//                imgMetadata.colorSpace = colorModel
//            }
//            
//            if let colorProfile = dict["ProfileName"] as? String {
//                imgMetadata.colorProfile = colorProfile
//            }
//            
//            for (key, value) in dict {
//                
//                if let keyStr = key as? String, keyStr.hasPrefix("{") && keyStr.hasSuffix("}"), value is NSDictionary {
//                    imgMetadata.type = keyStr.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "")
//                }
//            }
//            
//            if let bitDepthNum = dict["Depth"] as? NSNumber {
//                imgMetadata.bitDepth = bitDepthNum.intValue
//            }
//            
//            if let wd = dict["PixelWidth"] as? NSNumber, let ht = dict["PixelHeight"] as? NSNumber {
//                imgMetadata.dimensions = NSSize(width: CGFloat(wd.floatValue), height: CGFloat(ht.floatValue))
//            }
//            
//            if let xRes = dict["DPIWidth"] as? NSNumber, let yRes = dict["DPIHeight"] as? NSNumber {
//                imgMetadata.resolution = NSSize(width: CGFloat(xRes.floatValue), height: CGFloat(yRes.floatValue))
//            }
//            
//            if let hasAlphaNum = dict["HasAlpha"] as? NSNumber {
//                imgMetadata.hasAlpha = hasAlphaNum.intValue == 0 ? false : true
//            }
//            
//            return imgMetadata
//            
//        }
//        
//        return nil
//    }
}

extension String {
    
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

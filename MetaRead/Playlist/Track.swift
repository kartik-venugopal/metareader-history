import Cocoa
import AVFoundation

let nativeAudioExtensions: Set<String> = ["aac", "adts", "aif", "aiff", "aifc", "caf", "mp3", "m4a", "m4b", "m4r", "snd", "au", "sd2", "wav"]
let nonNativeAudioExtensions: Set<String> = ["flac", "oga", "opus", "wma", "dsf", "dsd", "dff", "mpc", "mp2", "ape", "wv", "dts", "mka", "ogg", "ac3", "amr", "aa3"]
let allAudioExtensions: Set<String> = {nativeAudioExtensions.union(nonNativeAudioExtensions)}()

class Track: Hashable {
    
    let file: URL
    let fileExt: String
    
    let isNativelySupported: Bool
    
    var defaultDisplayName: String
    
    var duration: Double = 0

    var title: String?
    var artist: String?
    
    var artistTitleString: String? {
        
        if let theArtist = artist, let theTitle = title {
            return "\(theArtist) - \(theTitle)"
        }
        
        return title
    }
    
    var album: String?
    var genre: String?
    
    var art: NSImage?
    
    var trackNumber: Int?
    var totalTracks: Int?
    
    var displayedTrackNum: String? {
        
        let trackNum = self.trackNumber
        let trackTotal = self.totalTracks
        
        // If both the track number and total tracks tags are present, return a formatted string with both tags.
        if let theTrackNum = trackNum, let theTrackTotal = trackTotal {
            return "\(theTrackNum) / \(theTrackTotal)"
            
        } else {
            
            // No total tracks tag present, return the track number tag if present.
            return trackNum == nil ? nil : "\(trackNum!)"
        }
    }
    
    var discNumber: Int?
    var totalDiscs: Int?
    
    var displayedDiscNum: String? {
        
        let discNum = self.discNumber
        let discTotal = self.totalDiscs
        
        // If both the disc number and total discs tags are present, return a formatted string with both tags.
        if let theDiscNum = discNum, let theDiscTotal = discTotal {
            return "\(theDiscNum) / \(theDiscTotal)"
            
        } else {
            
            // No total discs tag present, return the disc number tag if present.
            return discNum == nil ? nil : "\(discNum!)"
        }
    }
    
    var year: Int?
    
    var lyrics: String?
    
    // Generic metadata
    var genericMetadata: [String: String] = [:]
    
    init(_ file: URL) {
        
        self.file = file
        self.fileExt = file.pathExtension.lowercased()
        self.defaultDisplayName = file.deletingPathExtension().lastPathComponent
        
        self.isNativelySupported = nativeAudioExtensions.contains(fileExt)
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.file == rhs.file
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(file.path)
    }
}

extension AVMetadataItem {
    
    var commonKeyAsString: String? {
        return commonKey?.rawValue
    }
    
    var keyAsString: String? {
        
        if let key = self.key as? String {
            return StringUtils.cleanUpString(key).trim()
        }
        
        if let id = self.identifier {
            
            let tokens = id.rawValue.split(separator: "/")
            if tokens.count == 2 {
                return StringUtils.cleanUpString(String(tokens[1].trim().replacingOccurrences(of: "%A9", with: "@"))).trim()
            }
        }
        
        return nil
    }
    
    var valueAsString: String? {

        if !StringUtils.isStringEmpty(self.stringValue) {
            return self.stringValue
        }
        
        if let number = self.numberValue {
            return String(describing: number)
        }
        
        if let data = self.dataValue {
            return String(data: data, encoding: .utf8)
        }
        
        if let date = self.dateValue {
            return String(describing: date)
        }
        
        return nil
    }
    
    var valueAsNumericalString: String {
        
        if !StringUtils.isStringEmpty(self.stringValue), let num = Int(self.stringValue!) {
            return String(describing: num)
        }
        
        if let number = self.numberValue {
            return String(describing: number)
        }
        
        if let data = self.dataValue, let num = Int(data.hexEncodedString(), radix: 16) {
            return String(describing: num)
        }
        
        return "0"
    }
}

extension Data {
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

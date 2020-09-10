import Cocoa

class DefaultFFMpegMetadataParser: FFMpegMetadataParser {
    
    private let ignoredKeys: [String] = ["priv.www.amazon.com"]
    
    func mapTrack(_ meta: FFmpegMetadataReaderContext) {
        
        let metadata = meta.otherMetadata
        
        for (key, value) in meta.map {
            
            for iKey in ignoredKeys {
                
                if !key.lowercased().contains(iKey) {
                    metadata.genericFields[formatKey(key)] = value
                }
            }
            
            meta.map.removeValue(forKey: key)
        }
    }
    
    func hasMetadataForTrack(_ meta: FFmpegMetadataReaderContext) -> Bool {
        !meta.otherMetadata.genericFields.isEmpty
    }

    private func formatKey(_ key: String) -> String {
        
        let tokens = key.split(separator: "_")
        var fTokens = [String]()
        
        tokens.forEach({fTokens.append(String($0).capitalizingFirstLetter())})
        
        return fTokens.joined(separator: " ")
    }
    
    func getYear(_ meta: FFmpegMetadataReaderContext) -> Int? {
            
    //        if let yearString = meta.vorbisMetadata?.essentialFields[key_year] {
    //            return ParserUtils.parseYear(yearString)
    //        }
            
            return nil
        }
}

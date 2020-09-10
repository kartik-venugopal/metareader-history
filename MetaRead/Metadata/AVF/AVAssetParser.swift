import Cocoa
import AVFoundation

protocol AVAssetParser {
    
    var keySpace: AVMetadataKeySpace {get}
    
    func getDuration(_ meta: AVFMetadata) -> Double?
    
    func getTitle(_ meta: AVFMetadata) -> String?
    
    func getArtist(_ meta: AVFMetadata) -> String?
    
    func getAlbum(_ meta: AVFMetadata) -> String?
    
    func getGenre(_ meta: AVFMetadata) -> String?
    
    func getLyrics(_ meta: AVFMetadata) -> String?
    
    func getDiscNumber(_ meta: AVFMetadata) -> (number: Int?, total: Int?)?
    
    func getTrackNumber(_ meta: AVFMetadata) -> (number: Int?, total: Int?)?
    
    func getArt(_ meta: AVFMetadata) -> NSImage?
    
    func getYear(_ meta: AVFMetadata) -> Int?
    
//    func getGenericMetadata(_ meta: AVFMetadata) -> [String: String]
    
    // ----------- Chapter-related functions
    
//    func getChapterTitle(_ items: [AVMetadataItem]) -> String?
}

extension AVAssetParser {
    
    func getDuration(_ meta: AVFMetadata) -> Double? {
        return nil
    }
    
    func getDiscNumber(_ meta: AVFMetadata) -> (number: Int?, total: Int?)? {
        return nil
    }
    
    func getTrackNumber(_ meta: AVFMetadata) -> (number: Int?, total: Int?)? {
        return nil
    }
    
    func getLyrics(_ meta: AVFMetadata) -> String? {
        return nil
    }
    
    func getYear(_ meta: AVFMetadata) -> Int? {
        return nil
    }
}

class AVFMetadata {
    
    let file: URL
    let asset: AVURLAsset
    
    let items: [AVMetadataItem]
    
    var common: [String: AVMetadataItem] = [:]
    var id3: [String: AVMetadataItem] = [:]
    var iTunes: [String: AVMetadataItem] = [:]
    
    var keySpaces: [AVMetadataKeySpace] = []
    
    init(file: URL) {
        
        self.file = file
        self.asset = AVURLAsset(url: file, options: nil)
        self.items = asset.metadata
        
        for item in items {
            
            if let key = item.commonKeyAsString {
                
                common[key] = item
                continue
            }
            
            if let keySpace = item.keySpace {
                
                switch keySpace {
                    
                case .id3:
                    
                    if let key = item.keyAsString {
                        id3[key] = item
                    }
                    
                case .iTunes:
                    
                    if let key = item.keyAsString {
                        iTunes[key] = item
                    }
                    
                case .common:
                
                    if let key = item.keyAsString {
                        common[key] = item
                    }
                    
                default:
                    
                    // iTunes long format
                    if keySpace.rawValue.lowercased() == "itlk", let key = item.keyAsString {
                        iTunes[key] = item
                    }
                }
            }
        }
        
        if !common.isEmpty {
            keySpaces.append(.common)
        }
        
        let fileExt = file.pathExtension.lowercased()
        
        switch fileExt {
            
        case "m4a":
            
            keySpaces.append(.iTunes)
            
            if !id3.isEmpty {
                keySpaces.append(.id3)
            }
            
        default:
            
            keySpaces.append(.id3)
            
            if !iTunes.isEmpty {
                keySpaces.append(.iTunes)
            }
        }
    }
}

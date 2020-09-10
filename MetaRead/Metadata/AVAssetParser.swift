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

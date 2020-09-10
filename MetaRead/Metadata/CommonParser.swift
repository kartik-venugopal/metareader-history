import Cocoa
import AVFoundation

fileprivate let keySpace: String = AVMetadataKeySpace.common.rawValue

fileprivate let key_title = AVMetadataKey.commonKeyTitle.rawValue
fileprivate let key_artist = AVMetadataKey.commonKeyArtist.rawValue
fileprivate let key_album = AVMetadataKey.commonKeyAlbumName.rawValue
fileprivate let key_genre = AVMetadataKey.commonKeyType.rawValue
fileprivate let key_art: String = AVMetadataKey.commonKeyArtwork.rawValue
fileprivate let id_art: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.commonKeyArtwork.rawValue, keySpace: AVMetadataKeySpace.common)!

fileprivate let key_language: String = AVMetadataKey.commonKeyLanguage.rawValue

fileprivate let essentialFieldKeys: Set<String> = [key_title, key_artist, key_album, key_genre, key_art]

class CommonParser: AVAssetParser {
    
    var keySpace: AVMetadataKeySpace {.common}
    
    func getTitle(_ meta: AVFMetadata) -> String? {
        
        if let titleItem = meta.common[key_title] {
            return titleItem.stringValue
        }
        
        return nil
    }
    
    func getArtist(_ meta: AVFMetadata) -> String? {
        
        if let artistItem = meta.common[key_artist] {
            return artistItem.stringValue
        }
        
        return nil
    }
    
    func getAlbum(_ meta: AVFMetadata) -> String? {
        
        if let albumItem = meta.common[key_album] {
            return albumItem.stringValue
        }
        
        return nil
    }
    
    func getGenre(_ meta: AVFMetadata) -> String? {
        
        if let genreItem = meta.common[key_genre] {
            return genreItem.stringValue
        }
        
        return nil
    }
    
    func getArt(_ meta: AVFMetadata) -> NSImage? {
        
        if let item = meta.common[key_art], let imgData = item.dataValue, let image = NSImage(data: imgData) {
            return image
        }
        
        return nil
    }
}

import Cocoa
import AVFoundation

class ID3Parser: AVAssetParser, FFMpegMetadataParser {
    
    static let instance = ID3Parser()
    
    var keySpace: AVMetadataKeySpace {.id3}
    
    private let keys_duration: [String] = [ID3_V24Spec.key_duration, ID3_V22Spec.key_duration]
    
    private let keys_title: [String] = [ID3_V24Spec.key_title, ID3_V22Spec.key_title, ID3_V1Spec.key_title]
    
    private let keys_artist: [String] = [ID3_V24Spec.key_artist, ID3_V22Spec.key_artist, ID3_V1Spec.key_artist, ID3_V24Spec.key_originalArtist, ID3_V22Spec.key_originalArtist]
    private let keys_album: [String] = [ID3_V24Spec.key_album, ID3_V22Spec.key_album, ID3_V1Spec.key_album, ID3_V24Spec.key_originalAlbum, ID3_V22Spec.key_originalAlbum]
    private let keys_genre: [String] = [ID3_V24Spec.key_genre, ID3_V22Spec.key_genre, ID3_V1Spec.key_genre]
    
    private let keys_discNumber: [String] = [ID3_V24Spec.key_discNumber, ID3_V22Spec.key_discNumber]
    private let keys_trackNumber: [String] = [ID3_V24Spec.key_trackNumber, ID3_V22Spec.key_trackNumber, ID3_V1Spec.key_trackNumber]
    
    private let keys_year: [String] = [ID3_V24Spec.key_year, ID3_V22Spec.key_year, ID3_V24Spec.key_originalReleaseYear, ID3_V22Spec.key_originalReleaseYear, ID3_V24Spec.key_date, ID3_V22Spec.key_date]
    
    private let keys_lyrics: [String] = [ID3_V24Spec.key_lyrics, ID3_V22Spec.key_lyrics, ID3_V24Spec.key_syncLyrics, ID3_V22Spec.key_syncLyrics]
    private let keys_art: [String] = [ID3_V24Spec.key_art, ID3_V22Spec.key_art]
    
    private let keys_GEOB: [String] = [ID3_V24Spec.key_GEOB, ID3_V22Spec.key_GEO]
    private let keys_language: [String] = [ID3_V24Spec.key_language, ID3_V22Spec.key_language]
    private let keys_playCounter: [String] = [ID3_V24Spec.key_playCounter, ID3_V22Spec.key_playCounter]
    private let keys_compilation: [String] = [ID3_V24Spec.key_compilation, ID3_V22Spec.key_compilation]
    private let keys_mediaType: [String] = [ID3_V24Spec.key_mediaType, ID3_V22Spec.key_mediaType]
    
    private let essentialFieldKeys: Set<String> = {
        Set<String>().union(ID3_V1Spec.essentialFieldKeys).union(ID3_V22Spec.essentialFieldKeys).union(ID3_V24Spec.essentialFieldKeys)
    }()
    
    private let essentialFieldKeys_upperCased: Set<String> = {
        Set(Set<String>().union(ID3_V1Spec.essentialFieldKeys).union(ID3_V22Spec.essentialFieldKeys).union(ID3_V24Spec.essentialFieldKeys).map {$0.uppercased()})
    }()
    
    private let ignoredKeys: Set<String> = [ID3_V24Spec.key_private, ID3_V24Spec.key_tableOfContents, ID3_V24Spec.key_chapter]
    private let ignoredKeys_upperCased: Set<String> = Set([ID3_V24Spec.key_private, ID3_V24Spec.key_tableOfContents, ID3_V24Spec.key_chapter].map {$0.uppercased()})
    
    private let genericFields: [String: String] = {
        
        var map: [String: String] = [:]
        ID3_V22Spec.genericFields.forEach({(k,v) in map[k] = v})
        ID3_V24Spec.genericFields.forEach({(k,v) in map[k] = v})
        
        return map
    }()
    
    private let id_art: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.id3MetadataKeyAttachedPicture.rawValue, keySpace: AVMetadataKeySpace.id3)!
    
    private let replaceableKeyFields: Set<String> = {
        Set<String>().union(ID3_V22Spec.replaceableKeyFields).union(ID3_V24Spec.replaceableKeyFields)
    }()
    
    private let infoKeys_TXXX: [String: String] = ["albumartist": "Album Artist", "compatible_brands": "Compatible Brands", "gn_extdata": "Gracenote Data"]
    
    private func readableKey(_ key: String) -> String {
        return genericFields[key] ?? key.capitalizingFirstLetter()
    }
    
    func mapTrack(_ meta: FFmpegMetadataReaderContext) {
        
        let metadata = meta.id3Metadata
        
        for (key, value) in meta.map {
            
            let ucKey = key.uppercased()
            
            if !ignoredKeys_upperCased.contains(ucKey) {
                
                if essentialFieldKeys_upperCased.contains(ucKey) {
                    
                    metadata.essentialFields[ucKey] = value
                    meta.map.removeValue(forKey: key)
                    
                } else if genericFields[ucKey] != nil {
                    
                    metadata.genericFields[ucKey] = value
                    meta.map.removeValue(forKey: key)
                }
                
            } else {
                meta.map.removeValue(forKey: key)
            }
        }
    }
    
    func hasMetadataForTrack(_ meta: FFmpegMetadataReaderContext) -> Bool {
        !meta.id3Metadata.essentialFields.isEmpty
    }
    
    func getDuration(_ meta: AVFMetadata) -> Double? {
        
        for key in keys_duration {
            
            if let item = meta.id3[key], let durationStr = item.stringValue, let durationMsecs = Double(durationStr) {
                return durationMsecs / 1000
            }
        }
        
        return nil
    }
    
    func getTitle(_ meta: AVFMetadata) -> String? {
        
        for key in keys_title {

            if let titleItem = meta.id3[key] {
                return titleItem.stringValue
            }
        }
        
        return nil
    }
    
    func getArtist(_ meta: AVFMetadata) -> String? {
        
        for key in keys_artist {

            if let artistItem = meta.id3[key] {
                return artistItem.stringValue
            }
        }
        
        return nil
    }
    
    func getAlbum(_ meta: AVFMetadata) -> String? {
        
        for key in keys_album {

            if let albumItem = meta.id3[key] {
                return albumItem.stringValue
            }
        }
        
        return nil
    }
    
    func getGenre(_ meta: AVFMetadata) -> String? {
        
        for key in keys_genre {

            if let genreItem = meta.id3[key] {
                return ParserUtils.getID3Genre(genreItem)
            }
        }
        
        return nil
    }
    
    func getDiscNumber(_ meta: AVFMetadata) -> (number: Int?, total: Int?)? {
        
        for key in keys_discNumber {
            
            if let item = meta.id3[key] {
                return ParserUtils.parseDiscOrTrackNumber(item)
            }
        }
        
        return nil
    }
    
    func getTrackNumber(_ meta: AVFMetadata) -> (number: Int?, total: Int?)? {
        
        for key in keys_trackNumber {
            
            if let item = meta.id3[key] {
                return ParserUtils.parseDiscOrTrackNumber(item)
            }
        }
        
        return nil
    }

    func getArt(_ meta: AVFMetadata) -> NSImage? {
        
        for key in keys_art {
            
            if let item = meta.id3[key], let imgData = item.dataValue, let image = NSImage(data: imgData) {
                return image
            }
        }
        
        return nil
    }
    
    func getLyrics(_ meta: AVFMetadata) -> String? {
        
        for key in keys_lyrics {

            if let lyricsItem = meta.id3[key] {
                return lyricsItem.stringValue
            }
        }
        
        return nil
    }
    
    func getYear(_ meta: AVFMetadata) -> Int? {
        
        for key in keys_year {
            
            if let item = meta.id3[key] {
                return ParserUtils.parseYear(item)
            }
        }
        
        return nil
    }
    
    // MARK: FFmpeg
   
    func getTitle(_ meta: FFmpegMetadataReaderContext) -> String? {
        
        for key in keys_title {
            
            if let title = meta.id3Metadata.essentialFields[key] {
                return title
            }
        }
        
        return nil
    }
 
    func getArtist(_ meta: FFmpegMetadataReaderContext) -> String? {
        
        for key in keys_artist {
            
            if let artist = meta.id3Metadata.essentialFields[key] {
                return artist
            }
        }
        
        return nil
    }
  
    
    func getAlbum(_ meta: FFmpegMetadataReaderContext) -> String? {
        
        for key in keys_album {
            
            if let album = meta.id3Metadata.essentialFields[key] {
                return album
            }
        }
        
        return nil
    }
    
    func getGenre(_ meta: FFmpegMetadataReaderContext) -> String? {
        
        for key in keys_genre {
            
            if let genre = meta.id3Metadata.essentialFields[key] {
                return genre
            }
        }
        
        return nil
    }
    
    
    func getDiscNumber(_ meta: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
        
        for key in keys_discNumber {
            
            if let discNumStr = meta.id3Metadata.essentialFields[key] {
                return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
            }
        }
        
        return nil
    }
    
    func getTotalDiscs(_ meta: FFmpegMetadataReaderContext) -> Int? {
        return nil
    }
   
    
    func getTrackNumber(_ meta: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
        
        for key in keys_trackNumber {
            
            if let trackNumStr = meta.id3Metadata.essentialFields[key] {
                return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
            }
        }
        
        return nil
    }
    
    func getTotalTracks(_ meta: FFmpegMetadataReaderContext) -> Int? {
        return nil
    }
    
    func getLyrics(_ meta: FFmpegMetadataReaderContext) -> String? {
        
        for key in keys_lyrics {
            
            if let lyrics = meta.id3Metadata.essentialFields[key] {
                return lyrics
            }
        }
        
        return nil
    }
    
    // TODO
    func getYear(_ meta: FFmpegMetadataReaderContext) -> Int? {
        return nil
    }
}

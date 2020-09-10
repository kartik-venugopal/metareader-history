import Cocoa

fileprivate let key_title = "title"
fileprivate let key_artist = "artist"
fileprivate let key_album = "album"
fileprivate let key_genre = "genre"

fileprivate let key_disc = "disc"
fileprivate let key_track = "track"

fileprivate let key_lyrics = "lyrics"

fileprivate let key_albumArtist = "album_artist"
fileprivate let key_comment = "comment"
fileprivate let key_composer = "composer"
fileprivate let key_performer = "performer"
fileprivate let key_publisher = "publisher"
fileprivate let key_copyright = "copyright"

fileprivate let key_encodedBy = "encoded_by"
fileprivate let key_encoder = "encoder"
fileprivate let key_language = "language"
fileprivate let key_date = "date"

class CommonFFMpegMetadataParser: FFMpegMetadataParser {
    
    private let essentialKeys: Set<String> = [key_title, key_artist, key_album, key_genre, key_disc, key_track, key_date, key_lyrics]
    
    private let genericKeys: [String: String] = [
        
        key_albumArtist: "Album Artist",
        key_composer: "Composer",
        key_performer: "Performer",
        key_publisher: "Publisher",
        key_copyright: "Copyright",
        key_encodedBy: "Encoded By",
        key_encoder: "Encoder",
        key_language: "Language",
        key_comment: "Comment"
    ]
    
    func mapTrack(_ meta: FFmpegMetadataReaderContext) {
        
        let metadata = meta.commonMetadata
        
        for (key, value) in meta.map {
            
            let lcKey = key.lowercased().trim()
            
            if essentialKeys.contains(lcKey) {
                
                metadata.essentialFields[lcKey] = value
                meta.map.removeValue(forKey: key)
                
            } else if genericKeys[lcKey] != nil {
                
                metadata.genericFields[lcKey] = value
                meta.map.removeValue(forKey: key)
            }
        }
    }
    
    func hasMetadataForTrack(_ meta: FFmpegMetadataReaderContext) -> Bool {
        !meta.commonMetadata.essentialFields.isEmpty
    }
    
    func getTitle(_ meta: FFmpegMetadataReaderContext) -> String? {
        return meta.commonMetadata.essentialFields[key_title]
    }
    
    func getArtist(_ meta: FFmpegMetadataReaderContext) -> String? {
        return meta.commonMetadata.essentialFields[key_artist]
    }
    
    func getAlbum(_ meta: FFmpegMetadataReaderContext) -> String? {
        return meta.commonMetadata.essentialFields[key_album]
    }
    
    func getGenre(_ meta: FFmpegMetadataReaderContext) -> String? {
        return meta.commonMetadata.essentialFields[key_genre]
    }
    
    func getLyrics(_ meta: FFmpegMetadataReaderContext) -> String? {
        return meta.commonMetadata.essentialFields[key_lyrics]
    }
    
    func getDiscNumber(_ meta: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = meta.commonMetadata.essentialFields[key_disc] {
            return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
        }
        
        return nil
    }
    
    func getTotalDiscs(_ meta: FFmpegMetadataReaderContext) -> Int? {
        return nil
    }
    
    func getTrackNumber(_ meta: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
        
        if let trackNumStr = meta.commonMetadata.essentialFields[key_track] {
            return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
        }
        
        return nil
    }
    
    func getTotalTracks(_ meta: FFmpegMetadataReaderContext) -> Int? {
        return nil
    }
    
    func getYear(_ meta: FFmpegMetadataReaderContext) -> Int? {
        
        if let yearString = meta.commonMetadata.essentialFields[key_date] {
            return ParserUtils.parseYear(yearString)
        }
        
        return nil
    }
    
    func readableKey(_ key: String) -> String {
        return genericKeys[key] ?? key.capitalizingFirstLetter()
    }
}
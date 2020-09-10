import Cocoa
import AVFoundation

class ID3FFmpegParser: FFMpegMetadataParser {
    
    static let instance = ID3FFmpegParser()
    
    var keySpace: AVMetadataKeySpace {.id3}
    
    private let keys_duration: [String] = [ID3_V24Spec.key_duration, ID3_V22Spec.key_duration].map {$0.lowercased()}
    
    private let keys_title: [String] = [ID3_V24Spec.key_title, ID3_V22Spec.key_title, ID3_V1Spec.key_title].map {$0.lowercased()}
    
    private let keys_artist: [String] = [ID3_V24Spec.key_artist, ID3_V22Spec.key_artist, ID3_V1Spec.key_artist, ID3_V24Spec.key_originalArtist, ID3_V22Spec.key_originalArtist].map {$0.lowercased()}
    private let keys_album: [String] = [ID3_V24Spec.key_album, ID3_V22Spec.key_album, ID3_V1Spec.key_album, ID3_V24Spec.key_originalAlbum, ID3_V22Spec.key_originalAlbum].map {$0.lowercased()}
    private let keys_genre: [String] = [ID3_V24Spec.key_genre, ID3_V22Spec.key_genre, ID3_V1Spec.key_genre].map {$0.lowercased()}
    
    private let keys_discNumber: [String] = [ID3_V24Spec.key_discNumber, ID3_V22Spec.key_discNumber].map {$0.lowercased()}
    private let keys_trackNumber: [String] = [ID3_V24Spec.key_trackNumber, ID3_V22Spec.key_trackNumber, ID3_V1Spec.key_trackNumber].map {$0.lowercased()}
    
    private let keys_year: [String] = [ID3_V24Spec.key_year, ID3_V22Spec.key_year, ID3_V24Spec.key_originalReleaseYear, ID3_V22Spec.key_originalReleaseYear, ID3_V24Spec.key_date, ID3_V22Spec.key_date].map {$0.lowercased()}
    
    private let keys_lyrics: [String] = [ID3_V24Spec.key_lyrics, ID3_V22Spec.key_lyrics, ID3_V24Spec.key_syncLyrics, ID3_V22Spec.key_syncLyrics].map {$0.lowercased()}
    private let keys_art: [String] = [ID3_V24Spec.key_art, ID3_V22Spec.key_art].map {$0.lowercased()}
    
    private let essentialFieldKeys: Set<String> = {
        
        Set<String>().union(ID3_V1Spec.essentialFieldKeys.map {$0.lowercased()}).union(ID3_V22Spec.essentialFieldKeys.map {$0.lowercased()}).union(ID3_V24Spec.essentialFieldKeys.map {$0.lowercased()})
    }()
    
    private let ignoredKeys: Set<String> = Set([ID3_V24Spec.key_private, ID3_V24Spec.key_tableOfContents, ID3_V24Spec.key_chapter].map {$0.lowercased()})
    
    private let genericFields: [String: String] = {
        
        var map: [String: String] = [:]
        ID3_V22Spec.genericFields.forEach({(k,v) in map[k.lowercased()] = v})
        ID3_V24Spec.genericFields.forEach({(k,v) in map[k.lowercased()] = v})
        
        return map
    }()
    
    func mapTrack(_ meta: FFmpegMetadataReaderContext) {
        
        let metadata = meta.id3Metadata
        
        for key in meta.map.keys {
            
            let lcKey = key.lowercased().trim()
            
            if !ignoredKeys.contains(lcKey) {
                
                if essentialFieldKeys.contains(lcKey) {
                    
                    metadata.essentialFields[lcKey] = meta.map.removeValue(forKey: key)
                    
                } else if genericFields[lcKey] != nil {
                    
                    metadata.genericFields[lcKey] = meta.map.removeValue(forKey: key)
                }
                
            } else {
                meta.map.removeValue(forKey: key)
            }
        }
    }
    
    func hasMetadataForTrack(_ meta: FFmpegMetadataReaderContext) -> Bool {
        !meta.id3Metadata.essentialFields.isEmpty
    }
   
    func getTitle(_ meta: FFmpegMetadataReaderContext) -> String? {
        keys_title.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }
 
    func getArtist(_ meta: FFmpegMetadataReaderContext) -> String? {
        keys_artist.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }
    
    func getAlbum(_ meta: FFmpegMetadataReaderContext) -> String? {
        keys_album.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }
    
    func getGenre(_ meta: FFmpegMetadataReaderContext) -> String? {
        keys_genre.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }
    
    func getDiscNumber(_ meta: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = keys_discNumber.firstNonNilMappedValue({meta.id3Metadata.essentialFields[$0]}) {
            return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
        }
        
        return nil
    }
    
    func getTrackNumber(_ meta: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
        
        if let trackNumStr = keys_trackNumber.firstNonNilMappedValue({meta.id3Metadata.essentialFields[$0]}) {
            return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
        }
        
        return nil
    }
    
    func getLyrics(_ meta: FFmpegMetadataReaderContext) -> String? {
        keys_lyrics.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }
    
    func getYear(_ meta: FFmpegMetadataReaderContext) -> Int? {
        
        if let yearString = keys_year.firstNonNilMappedValue({meta.id3Metadata.essentialFields[$0]}) {
            return ParserUtils.parseYear(yearString)
        }
        
        return nil
    }
    
    func getDuration(_ meta: FFmpegMetadataReaderContext) -> Double? {
        
        if let durationStr = keys_duration.firstNonNilMappedValue({meta.id3Metadata.essentialFields[$0]}), let durationMsecs = Double(durationStr) {
            return durationMsecs / 1000
        }
        
        return nil
    }
}

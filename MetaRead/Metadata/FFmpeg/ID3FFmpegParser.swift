import Cocoa
import AVFoundation

class ID3FFmpegParser: FFMpegMetadataParser {
    
    static let instance = ID3FFmpegParser()
    
    private let keys_duration: [String] = [ID3_V24Spec.key_duration, ID3_V22Spec.key_duration].map {$0.lowercased()}
    
    private let keys_title: [String] = [ID3_V24Spec.key_title, ID3_V22Spec.key_title, ID3_V1Spec.key_title].map {$0.lowercased()}
    
    private let keys_artist: [String] = [ID3_V24Spec.key_artist, ID3_V22Spec.key_artist, ID3_V1Spec.key_artist, ID3_V24Spec.key_originalArtist, ID3_V22Spec.key_originalArtist].map {$0.lowercased()}
    private let keys_albumArtist: [String] = [ID3_V24Spec.key_albumArtist, ID3_V22Spec.key_albumArtist].map {$0.lowercased()}
    private let keys_album: [String] = [ID3_V24Spec.key_album, ID3_V22Spec.key_album, ID3_V1Spec.key_album, ID3_V24Spec.key_originalAlbum, ID3_V22Spec.key_originalAlbum].map {$0.lowercased()}
    private let keys_genre: [String] = [ID3_V24Spec.key_genre, ID3_V22Spec.key_genre, ID3_V1Spec.key_genre].map {$0.lowercased()}
    private let keys_composer: [String] = [ID3_V24Spec.key_composer, ID3_V22Spec.key_composer].map {$0.lowercased()}
    private let keys_conductor: [String] = [ID3_V24Spec.key_conductor, ID3_V22Spec.key_conductor].map {$0.lowercased()}
    private let keys_lyricist: [String] = [ID3_V24Spec.key_lyricist, ID3_V22Spec.key_lyricist, ID3_V24Spec.key_originalLyricist, ID3_V22Spec.key_originalLyricist].map {$0.lowercased()}
    
    private let keys_discNumber: [String] = [ID3_V24Spec.key_discNumber, ID3_V22Spec.key_discNumber].map {$0.lowercased()}
    private let keys_trackNumber: [String] = [ID3_V24Spec.key_trackNumber, ID3_V22Spec.key_trackNumber, ID3_V1Spec.key_trackNumber].map {$0.lowercased()}
    
    private let keys_year: [String] = [ID3_V24Spec.key_year, ID3_V22Spec.key_year, ID3_V24Spec.key_originalReleaseYear, ID3_V22Spec.key_originalReleaseYear, ID3_V24Spec.key_date, ID3_V22Spec.key_date].map {$0.lowercased()}
    
    private let keys_bpm: [String] = [ID3_V24Spec.key_bpm, ID3_V22Spec.key_bpm].map {$0.lowercased()}
    
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
    
    func mapTrack(_ meta: FFmpegMappedMetadata) {
        
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
    
    func hasMetadataForTrack(_ meta: FFmpegMappedMetadata) -> Bool {
        !meta.id3Metadata.essentialFields.isEmpty
    }
   
    func getTitle(_ meta: FFmpegMappedMetadata) -> String? {
        keys_title.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }
 
    func getArtist(_ meta: FFmpegMappedMetadata) -> String? {
        keys_artist.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }
    
    func getAlbumArtist(_ meta: FFmpegMappedMetadata) -> String? {
        keys_albumArtist.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }
    
    func getAlbum(_ meta: FFmpegMappedMetadata) -> String? {
        keys_album.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }
    
    func getComposer(_ meta: FFmpegMappedMetadata) -> String? {
        keys_composer.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }
    
    func getConductor(_ meta: FFmpegMappedMetadata) -> String? {
        keys_conductor.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }
    
    func getLyricist(_ meta: FFmpegMappedMetadata) -> String? {
        keys_lyricist.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }
    
    func getGenre(_ meta: FFmpegMappedMetadata) -> String? {
        keys_genre.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }
    
    func getDiscNumber(_ meta: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = keys_discNumber.firstNonNilMappedValue({meta.id3Metadata.essentialFields[$0]}) {
            return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
        }
        
        return nil
    }
    
    func getTrackNumber(_ meta: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let trackNumStr = keys_trackNumber.firstNonNilMappedValue({meta.id3Metadata.essentialFields[$0]}) {
            return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
        }
        
        return nil
    }
    
    func getLyrics(_ meta: FFmpegMappedMetadata) -> String? {
        keys_lyrics.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }
    
    func getYear(_ meta: FFmpegMappedMetadata) -> Int? {
        
        if let yearString = keys_year.firstNonNilMappedValue({meta.id3Metadata.essentialFields[$0]}) {
            return ParserUtils.parseYear(yearString)
        }
        
        return nil
    }
    
    func getBPM(_ meta: FFmpegMappedMetadata) -> Int? {
        
        if let bpmString = keys_bpm.firstNonNilMappedValue({meta.id3Metadata.essentialFields[$0]}) {
            return ParserUtils.parseBPM(bpmString)
        }
        
        return nil
    }
    
    func getDuration(_ meta: FFmpegMappedMetadata) -> Double? {
        
        if let durationStr = keys_duration.firstNonNilMappedValue({meta.id3Metadata.essentialFields[$0]}) {
            return ParserUtils.parseDuration(durationStr)
        }
        
        return nil
    }
}

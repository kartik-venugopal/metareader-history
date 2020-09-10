import Cocoa
import AVFoundation

fileprivate let key_title = "title"

fileprivate let key_artist = "author"
fileprivate let key_originalArtist = "originalartist"
fileprivate let key_albumArtist = "albumartist"

fileprivate let keys_artist: [String] = [key_artist, key_albumArtist, key_originalArtist]

fileprivate let key_album = "albumtitle"
fileprivate let key_originalAlbum = "originalalbumtitle"

fileprivate let key_genre = "genre"
fileprivate let key_genreId = "genreid"

fileprivate let key_composer = "composer"
fileprivate let key_conductor = "conductor"

fileprivate let key_lyricist = "originallyricist"

fileprivate let key_duration = "duration"
fileprivate let key_totalDuration = "totalduration"

fileprivate let key_disc = "partofset"
fileprivate let key_discTotal = "disctotal"

fileprivate let key_track = "tracknumber"
fileprivate let key_track_zeroBased = "track"
fileprivate let key_trackTotal = "tracktotal"

fileprivate let key_year = "year"
fileprivate let key_originalYear = "originalreleaseyear"

fileprivate let key_lyrics = "lyrics"
fileprivate let key_syncLyrics = "lyrics_synchronised"

fileprivate let key_encodingTime = "encodingtime"
fileprivate let key_isVBR = "isvbr"
fileprivate let key_isCompilation = "iscompilation"

fileprivate let key_language = "language"

// Used for parsing "Encoding time" field
//fileprivate let fileTime_baseTime: Date = {
//
//    var calendar = Calendar(identifier: .gregorian)
//    let components = DateComponents(year: 1601, month: 1, day: 1, hour: 0, minute: 0, second: 0)
//    return calendar.date(from: components)!
//}()

//fileprivate let dateFormatter: DateFormatter = {
//   
//    let formatter = DateFormatter()
//    formatter.dateFormat = "MMMM dd, yyyy  'at'  hh:mm:ss a"
//    return formatter
//}()

class WMParser: FFMpegMetadataParser {
    
    private let keyPrefix = "wm/"
    
    private let essentialKeys: Set<String> = [key_title, key_artist, key_originalArtist, key_albumArtist, key_album, key_originalAlbum, key_genre, key_genreId,
                                              key_disc, key_discTotal, key_track, key_track_zeroBased, key_trackTotal, key_year, key_originalYear, key_lyrics]
    
    private let ignoredKeys: Set<String> = ["wmfsdkneeded"]
    
    func mapTrack(_ meta: FFmpegMetadataReaderContext) {
        
        let metadata = meta.wmMetadata
        
        for key in meta.map.keys {
            
            let lcKey = key.lowercased().trim().replacingOccurrences(of: keyPrefix, with: "")
            
            if !ignoredKeys.contains(lcKey) {
                
                if essentialKeys.contains(lcKey) {
                    
                    metadata.essentialFields[lcKey] = meta.map.removeValue(forKey: key)
                    
                } else if genericKeys[lcKey] != nil {
                    
                    metadata.genericFields[lcKey] = meta.map.removeValue(forKey: key)
                }
                
            } else {
                meta.map.removeValue(forKey: key)
            }
        }
    }
    
    func hasMetadataForTrack(_ meta: FFmpegMetadataReaderContext) -> Bool {
        !meta.wmMetadata.essentialFields.isEmpty
    }
    
    func getTitle(_ meta: FFmpegMetadataReaderContext) -> String? {
        meta.wmMetadata.essentialFields[key_title]
    }
    
    func getArtist(_ meta: FFmpegMetadataReaderContext) -> String? {
        keys_artist.firstNonNilMappedValue({meta.wmMetadata.essentialFields[$0]})
    }
    
    func getAlbum(_ meta: FFmpegMetadataReaderContext) -> String? {
        meta.wmMetadata.essentialFields[key_album] ?? meta.wmMetadata.essentialFields[key_originalAlbum]
    }
    
    func getComposer(_ meta: FFmpegMetadataReaderContext) -> String? {
        meta.wmMetadata.essentialFields[key_composer]
    }
    
    func getGenre(_ meta: FFmpegMetadataReaderContext) -> String? {
        
        if let genre = meta.wmMetadata.essentialFields[key_genre] {
            return genre
        }
        
        if let genreId = meta.wmMetadata.essentialFields[key_genreId]?.trim() {
            return ParserUtils.parseID3GenreNumericString(genreId)
        }
        
        return nil
    }
    
    func getDiscNumber(_ meta: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = meta.wmMetadata.essentialFields[key_disc] {
            return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
        }
        
        return nil
    }
    
    func getTotalDiscs(_ meta: FFmpegMetadataReaderContext) -> Int? {
        
        if let totalDiscsStr = meta.wmMetadata.essentialFields[key_discTotal]?.trim(), let totalDiscs = Int(totalDiscsStr) {
            return totalDiscs
        }
        
        return nil
    }
    
    func getTrackNumber(_ meta: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
        
        if let trackNumStr = meta.wmMetadata.essentialFields[key_track] {
            return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
        }
        
        // Zero-based track number
        if let trackNumStr = meta.wmMetadata.essentialFields[key_track_zeroBased], let trackNum = ParserUtils.parseDiscOrTrackNumberString(trackNumStr) {
            
            // Offset the track number by 1
            if let number = trackNum.number {
                return (number + 1, trackNum.total)
            }
            
            return trackNum
        }
        
        return nil
    }
    
    func getTotalTracks(_ meta: FFmpegMetadataReaderContext) -> Int? {
        
        if let totalTracksStr = meta.wmMetadata.essentialFields[key_trackTotal]?.trim(), let totalTracks = Int(totalTracksStr) {
            return totalTracks
        }
        
        return nil
    }
    
    func getYear(_ meta: FFmpegMetadataReaderContext) -> Int? {
        
        if let yearString = meta.wmMetadata.essentialFields[key_year] {
            return ParserUtils.parseYear(yearString)
        }
        
        return nil
    }
    
    func getLyrics(_ meta: FFmpegMetadataReaderContext) -> String? {
        
        for key in [key_lyrics, key_syncLyrics] {
        
            if let lyrics = meta.wmMetadata.essentialFields[key] {
                return lyrics
            }
        }
        
        return nil
    }
    
    private let genericKeys: [String: String] = {
        
        var map: [String: String] = [:]
        
        map["averagelevel"] = "Avg. Volume Level"
        
        map["peakvalue"] = "Peak Volume Level"
        
        map["description"] = "Comment"
        
        map["provider"] = "Provider"
        
        map["publisher"] = "Publisher"
        
        map["providerrating"] = "Provider Rating"
        
        map["providerstyle"] = "Provider Style"
        
        map["contentdistributor"] = "Content Distributor"
        
        map["wmfsdkversion"] = "Windows Media Format Version"

        map["encodingtime"] = "Encoding Timestamp"
        
        map["wmadrcpeakreference"] = "DRC Peak Reference"
        
        map["wmadrcaveragereference"] = "DRC Average Reference"
        
        map["uniquefileidentifier"] = "Unique File Identifier"
        
        map["modifiedby"] = "Remixer"
        
        map["subtitle"] = "Subtitle"
        
        map["setsubtitle"] = "Disc Subtitle"
        
        map["contentgroupdescription"] = "Grouping"
        
        map["albumartistsortorder"] = "Album Artist Sort Order"
        
        map["albumsortorder"] = "Album Sort Order"
        
        map["arranger"] = "Arranger"
        
        map["artistsortorder"] = "Artist Sort Order"
        
        map["asin"] = "ASIN"
        
        map["authorurl"] = "Official Artist Site Url"
        
        map["barcode"] = "Barcode"
        
        map["beatsperminute"] = "BPM (Beats Per Minute)"
        
        map["catalogno"] = "Catalog Number"
        
        map["comments"] = "Comment"
        
        map["iscompilation"] = "Part of a Compilation?"
        
        map["composersort"] = "Composer Sort Order"
        
        map["copyright"] = "Copyright"
        
        map["country"] = "Country"
        
        map["encodedby"] = "Encoded By"
        
        map["encodingsettings"] = "Encoder"
        
        map["engineer"] = "Engineer"
        
        map["fbpm"] = "Floating Point BPM"
        
        map["contentgroupdescription"] = "Grouping"
        
        map["isrc"] = "ISRC"
        
        map["initialkey"] = "Key"
        
        map["language"] = "Language"
        
        map["writer"] = "Writer"
        
        map["lyricsurl"] = "Lyrics Site Url"
        
        map["media"] = "Media"
        
        map["mediastationcallsign"] = "Service Provider"
        
        map["mediastationname"] = "Service Name"
        
        map["media"] = "Media"
        
        map["mixer"] = "Mixer"
        
        map["mood"] = "Mood"
        
        map["occasion"] = "Occasion"
        
        map["officialreleaseurl"] = "Official Release Site Url"
        
        map["originalfilename"] = "Original Filename"
        
        map["url_official_artist_site"] = "Official Artist Website"
        
        map["producer"] = "Producer"
        
        map["quality"] = "Quality"
        
        map["shareduserrating"] = "Rating"
        
        map["modifiedby"] = "Remixer"
        
        map["script"] = "Script"
        
        map["tags"] = "Tags"
        
        map["tempo"] = "Tempo"
        
        map["titlesortorder"] = "Title Sort Order"
        
        map["tool"] = "Encoder"
        
        map["toolname"] = "Encoder"
        
        map["toolversion"] = "Encoder Version"
        
        map["deviceconformancetemplate"] = "Device Conformance Template"
        
        map["isvbr"] = "Is VBR?"
        
        map["mediaprimaryclassid"] = "Primary Media Class ID"
        
        map["codec"] = "Codec"
        
        map["category"] = "Category"
        
        return map
    }()
    
    private func readableKey(_ key: String) -> String {
        
        let lcKey = key.lowercased()
        let trimmedKey = lcKey.replacingOccurrences(of: keyPrefix, with: "").trim()
        
        if let rKey = genericKeys[trimmedKey] {
            
            return rKey
            
        } else if let range = lcKey.range(of: trimmedKey) {
            
            return String(key[range.lowerBound..<range.upperBound]).capitalizingFirstLetter()
        }
        
        return key.capitalizingFirstLetter()
    }
    
    private func numericStringToBoolean(_ string: String) -> Bool? {
        
        if let num = Int(string.trim()) {
            return num != 0
        }
        
        return nil
    }
}

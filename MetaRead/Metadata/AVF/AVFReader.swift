import AVFoundation

class AVFReader {
    
    static let instance: AVFReader = AVFReader()
    
    let commonParser: CommonParser = CommonParser()
    let id3Parser: ID3Parser = ID3Parser()
    let iTunesParser: ITunesParser = ITunesParser()
    
    let parsersMap: [AVMetadataKeySpace: AVAssetParser]
    
    init() {
        parsersMap = [.common: commonParser, .id3: id3Parser, .iTunes: iTunesParser]
    }
    
    func loadMetadata(for track: Track) {
        
        let meta = AVFMetadata(file: track.file)
        let parsers = meta.keySpaces.compactMap {parsersMap[$0]}
        
        track.title = parsers.firstNonNilMappedValue {$0.getTitle(meta)}
        track.artist = parsers.firstNonNilMappedValue {$0.getArtist(meta)}
        track.albumArtist = parsers.firstNonNilMappedValue {$0.getAlbumArtist(meta)}
        track.album = parsers.firstNonNilMappedValue {$0.getAlbum(meta)}
        track.genre = parsers.firstNonNilMappedValue {$0.getGenre(meta)}
        track.year = parsers.firstNonNilMappedValue {$0.getYear(meta)}
        track.composer = parsers.firstNonNilMappedValue {$0.getComposer(meta)}
        track.conductor = parsers.firstNonNilMappedValue {$0.getConductor(meta)}
        track.performer = parsers.firstNonNilMappedValue{$0.getPerformer(meta)}
        track.lyricist = parsers.firstNonNilMappedValue {$0.getLyricist(meta)}
        
        let trackNum: (number: Int?, total: Int?)? = parsers.firstNonNilMappedValue {$0.getTrackNumber(meta)}
        track.trackNumber = trackNum?.number
        track.totalTracks = trackNum?.total
        
        let discNum: (number: Int?, total: Int?)? = parsers.firstNonNilMappedValue {$0.getDiscNumber(meta)}
        track.discNumber = discNum?.number
        track.totalDiscs = discNum?.total
        
        track.duration = meta.asset.duration.seconds
        
        if track.fileExt == "aac" {
            
            // Use brute force to compute duration
            DispatchQueue.global(qos: .userInitiated).async {
                
                do {
                    
                    let afile = try AVAudioFile(forReading: track.file)
                    track.duration = Double(afile.length) / afile.processingFormat.sampleRate
                    
                    var notif = Notification(name: Notification.Name("trackUpdated"))
                    notif.userInfo = ["track": track]
                    
                    NotificationCenter.default.post(notif)
                    
                } catch {
                    NSLog("\nProblem: \(error)")
                }
            }
            
        }
        
        track.art = parsers.firstNonNilMappedValue {$0.getArt(meta)}
    }
}

extension Array {
    
    func firstNonNilMappedValue<R>(_ mapFunc: (Element) -> R?) ->R? {

        for elm in self {

            if let result = mapFunc(elm) {
                return result
            }
        }

        return nil
    }
}

import Cocoa

class FFMpegReader {
    
    static let instance: FFMpegReader = FFMpegReader()
    
    private var allParsers: [FFMpegMetadataParser] = []
    
    private let genericMetadata_ignoreKeys: [String] = ["title", "artist", "duration", "disc", "track", "album", "genre"]
    
    let commonFFMpegParser = CommonFFMpegMetadataParser()
    let id3Parser = ID3FFmpegParser.instance
    let wmParser = WMParser()
    let vorbisParser = VorbisCommentParser()
    let apeParser = ApeV2Parser()
    let defaultParser = DefaultFFMpegMetadataParser()
    
    private var wmFileParsers: [FFMpegMetadataParser] = []
    private var vorbisFileParsers: [FFMpegMetadataParser] = []
    private var apeFileParsers: [FFMpegMetadataParser] = []
    
    private var parsersByExt: [String: [FFMpegMetadataParser]] = [:]
    
    init() {
        
        allParsers = [commonFFMpegParser, id3Parser, vorbisParser, apeParser, wmParser, defaultParser]
        wmFileParsers = [commonFFMpegParser, wmParser, id3Parser, vorbisParser, apeParser, defaultParser]
        vorbisFileParsers = [commonFFMpegParser, vorbisParser, apeParser, id3Parser, wmParser, defaultParser]
        apeFileParsers = [commonFFMpegParser, apeParser, vorbisParser, id3Parser, wmParser, defaultParser]
        
        parsersByExt =
        [
            "wma": wmFileParsers,
            "flac": vorbisFileParsers,
            "dsf": vorbisFileParsers,
            "ogg": vorbisFileParsers,
            "opus": vorbisFileParsers,
            "ape": apeFileParsers,
            "mpc": apeFileParsers
        ]
    }
    
    private func nilIfEmpty(_ string: String?) -> String? {
        return StringUtils.isStringEmpty(string) ? nil : string
    }
    
    func loadMetadata(for track: Track) {
        
        do {
            
            let fctx = try FFmpegFileContext(for: track.file)
            let context = FFmpegMetadataReaderContext(for: fctx)
            
            let allParsers = parsersByExt[context.fileType] ?? self.allParsers
            allParsers.forEach {$0.mapTrack(context)}
            
            let relevantParsers = allParsers.filter {$0.hasMetadataForTrack(context)}
            
            track.title = nilIfEmpty(relevantParsers.firstNonNilMappedValue {$0.getTitle(context)})
            track.artist = nilIfEmpty(relevantParsers.firstNonNilMappedValue {$0.getArtist(context)})
            track.albumArtist = nilIfEmpty(relevantParsers.firstNonNilMappedValue {$0.getAlbumArtist(context)})
            track.album = nilIfEmpty(relevantParsers.firstNonNilMappedValue {$0.getAlbum(context)})
            track.genre = nilIfEmpty(relevantParsers.firstNonNilMappedValue {$0.getGenre(context)})
            track.year = relevantParsers.firstNonNilMappedValue {$0.getYear(context)}
            track.composer = nilIfEmpty(relevantParsers.firstNonNilMappedValue {$0.getComposer(context)})
            track.lyricist = nilIfEmpty(relevantParsers.firstNonNilMappedValue {$0.getLyricist(context)})
            
            var trackNumberAndTotal = relevantParsers.firstNonNilMappedValue {$0.getTrackNumber(context)}
            if let trackNum = trackNumberAndTotal?.number, trackNumberAndTotal?.total == nil,
                let totalTracks = relevantParsers.firstNonNilMappedValue({$0.getTotalTracks(context)}) {
                
                trackNumberAndTotal = (trackNum, totalTracks)
            }
            
            track.trackNumber = trackNumberAndTotal?.number
            track.totalTracks = trackNumberAndTotal?.total
            
            var discNumberAndTotal = relevantParsers.firstNonNilMappedValue {$0.getDiscNumber(context)}
            if let discNum = discNumberAndTotal?.number, discNumberAndTotal?.total == nil,
                let totalDiscs = relevantParsers.firstNonNilMappedValue({$0.getTotalDiscs(context)}) {
                
                discNumberAndTotal = (discNum, totalDiscs)
            }
            
            track.discNumber = discNumberAndTotal?.number
            track.totalDiscs = discNumberAndTotal?.total
            
            track.duration = context.fileCtx.duration
            if track.duration == 0 || context.fileCtx.isRawAudioFile {
              
                if let durationFromMetadata = relevantParsers.firstNonNilMappedValue({$0.getDuration(context)}), durationFromMetadata > 0 {
                    track.duration = durationFromMetadata
                    
                } else {
                    
                    // Use brute force to compute duration
                    DispatchQueue.global(qos: .userInitiated).async {
                        
                        if let duration = FFmpegPacketTable(for: context.fileCtx)?.duration {
                            
                            track.duration = duration
                            
                            var notif = Notification(name: Notification.Name("trackUpdated"))
                            notif.userInfo = ["track": track]
                            
                            NotificationCenter.default.post(notif)
                        }
                    }
                }
            }
            
            if let imageStream = context.imageStream,
                let imageData = imageStream.attachedPic.data,
                let image = NSImage(data: imageData) {
                
                track.art = image
            }
            
        } catch let err as FormatContextInitializationError {
            NSLog("Track.init(): Couldn't init FFmpeg file context for '\(track.file.lastPathComponent)': \(err.description)")
        } catch {
            NSLog("Track.init(): Couldn't init FFmpeg file context for '\(track.file.lastPathComponent)': \(error)")
        }
    }
}

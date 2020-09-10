import Cocoa

class FFMpegReader {
    
    static let instance: FFMpegReader = FFMpegReader()
    
    private var allParsers: [FFMpegMetadataParser] = []
    
    private let genericMetadata_ignoreKeys: [String] = ["title", "artist", "duration", "disc", "track", "album", "genre"]
    
    let commonFFMpegParser = CommonFFMpegMetadataParser()
    let id3Parser = ID3Parser.instance
    let wmParser = WMParser()
    let vorbisParser = VorbisCommentParser()
    let apeParser = ApeV2Parser()
    let defaultParser = DefaultFFMpegMetadataParser()
    
    private var wmFileParsers: [FFMpegMetadataParser] = []
    private var vorbisFileParsers: [FFMpegMetadataParser] = []
    private var apeFileParsers: [FFMpegMetadataParser] = []
    
    init() {
        
        allParsers = [commonFFMpegParser, id3Parser, vorbisParser, apeParser, wmParser, defaultParser]
        wmFileParsers = [commonFFMpegParser, wmParser, id3Parser, vorbisParser, apeParser, defaultParser]
        vorbisFileParsers = [commonFFMpegParser, vorbisParser, apeParser, id3Parser, wmParser, defaultParser]
        apeFileParsers = [commonFFMpegParser, apeParser, vorbisParser, id3Parser, wmParser, defaultParser]
    }
    
    private func nilIfEmpty(_ string: String?) -> String? {
        return StringUtils.isStringEmpty(string) ? nil : string
    }
    
    func loadMetadata(for track: Track) {
        
        do {
            
            let fctx = try FFmpegFileContext(for: track.file)
            let context = FFmpegMetadataReaderContext(for: fctx)
            
            let st = CFAbsoluteTimeGetCurrent()
            let allParsers = parsersForTrack(context)
            let e1 = CFAbsoluteTimeGetCurrent()
            
            allParsers.forEach {$0.mapTrack(context)}
            
            let s2 = CFAbsoluteTimeGetCurrent()
            let relevantParsers = allParsers.filter {$0.hasMetadataForTrack(context)}
            let e2 = CFAbsoluteTimeGetCurrent()
            
            print("\nTime to determine parsers: \((e1 - st) * 1000) \((e2 - s2) * 1000)")
            
            track.title = nilIfEmpty(relevantParsers.firstNonNilMappedValue {$0.getTitle(context)})
            track.artist = nilIfEmpty(relevantParsers.firstNonNilMappedValue {$0.getArtist(context)})
            track.album = nilIfEmpty(relevantParsers.firstNonNilMappedValue {$0.getAlbum(context)})
            track.genre = nilIfEmpty(relevantParsers.firstNonNilMappedValue {$0.getGenre(context)})
            track.year = relevantParsers.firstNonNilMappedValue {$0.getYear(context)}
            
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
    
    private func parsersForTrack(_ context: FFmpegMetadataReaderContext) -> [FFMpegMetadataParser] {
        
        // TODO: Store these in a Dictionary for quick lookup
        
        switch context.fileType {
            
        case "wma":
            
            return wmFileParsers
            
        case "flac", "ogg", "opus":
            
            return vorbisFileParsers
            
        case "ape", "mpc":
            
            return apeFileParsers
            
        default:
            
            return allParsers
        }
    }
}

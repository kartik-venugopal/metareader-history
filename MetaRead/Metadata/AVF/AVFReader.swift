import AVFoundation

class AVFReader {
    
    static let instance: AVFReader = AVFReader()
    
    let commonParser: CommonParser = CommonParser()
    let id3Parser: ID3Parser = ID3Parser()
    let iTunesParser: ITunesParser = ITunesParser()
    
    let parsersMap: [AVMetadataKeySpace: AVAssetParser]
    
    let formatDescriptions: [CMFormatDescription.MediaSubType: String] = [
        
        .linearPCM: "Linear PCM",
        
        .ac3: "AC-3",
        .iec60958AC3: "IEC 60958 compliant AC-3",
        .enhancedAC3: "Enhanced AC-3",
        
        .appleIMA4: "Apple IMA 4:1 ADPCM",
        
        .mpeg4AAC: "MPEG-4 AAC",
        .mpeg4AAC_HE: "MPEG-4 HE AAC",
        .mpeg4AAC_HE_V2: "MPEG-4 HE AAC Version 2",
        .mpeg4AAC_LD: "MPEG-4 LD AAC",
        .mpeg4AAC_ELD: "MPEG-4 ELD AAC",
        .mpeg4AAC_ELD_SBR: "MPEG-4 ELD AAC w/ SBR extension",
        .mpeg4AAC_ELD_V2: "MPEG-4 ELD AAC Version 2",
        .mpeg4AAC_Spatial: "MPEG-4 Spatial AAC",
        .aacLCProtected: "AAC LC (Protected)",
        
        .mpeg4CELP: "MPEG-4 CELP",
        .mpeg4HVXC: "MPEG-4 HVXC",
        .mpeg4TwinVQ: "MPEG-4 TwinVQ",
        
        .mace3: "MACE 3:1",
        .mace6: "MACE 6:1",
        
        .uLaw: "µLaw 2:1",
        .aLaw: "aLaw 2:1",
        
        .qDesign: "QDesign music",
        .qDesign2: "QDesign2 music",
        
        .qualcomm: "QUALCOMM PureVoice",
        
        .mpegLayer1: "MPEG-1/2, Layer 1",
        .mpegLayer2: "MPEG-1/2, Layer 2",
        .mpegLayer3: "MPEG-1/2, Layer 3",
        
        .timeCode: "IO Audio",
        .midiStream: "MIDI",
        .parameterValueStream: "Audio Unit Parameter Value Stream",
        .appleLossless: "Apple Lossless",
        
        .mpegD_USAC: "MPEG-D USAC",
        .amr: "AMR Narrow Band",
        .amr_WB: "AMR Wide Band",
        .audible: "Audible",
        .iLBC: "iLBC",
        .dviIntelIMA: "DVI/Intel IMA ADPCM",
        .microsoftGSM: "Microsoft GSM 6.10",
        .aes3: "AES3-2003",
        
        .flac: "FLAC",
        .opus: "Opus"
    ]
    
    init() {
        parsersMap = [.common: commonParser, .id3: id3Parser, .iTunes: iTunesParser]
    }
    
    // File extension -> Kind of file description string
    static var kindOfFileCache: [String: String] = [:]
    
    static func kindOfFile(path: String, fileExt: String) -> String? {
        
        if let cachedValue = kindOfFileCache[fileExt] {
            return cachedValue
        }
        
        if let mditem = MDItemCreate(nil, path as CFString),
            let mdnames = MDItemCopyAttributeNames(mditem),
            let mdattrs = MDItemCopyAttributes(mditem, mdnames) as? [String: Any],
            let value = mdattrs[kMDItemKind as String] as? String {
            
            kindOfFileCache[fileExt] = value
            return value
        }
        
        return nil
    }
    
    func loadMetadata(for track: Track) {
        
        if let kindOfFile = Self.kindOfFile(path: track.file.path, fileExt: track.fileExt) {
            track.fileType = kindOfFile
        }
        
        let meta = AVFMetadata(file: track.file)
        
        if let assetTrack = meta.asset.tracks.first {
            track.audioFormat = formatDescriptions[assetTrack.format] ?? assetTrack.format4CharString
        }
        
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
        track.art = parsers.firstNonNilMappedValue {$0.getArt(meta)}
        
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
    }
}

extension AVAssetTrack {
    
    var formatDescription: CMFormatDescription {
        self.formatDescriptions.first as! CMFormatDescription
    }
    
    var format: CMFormatDescription.MediaSubType {
        formatDescription.mediaSubType
    }
    
    var format4CharString: String {
        format.rawValue.toString()
    }
}

extension FourCharCode {
    
    // Create a String representation of a FourCC
    func toString() -> String {
        
        let bytes: [CChar] = [
            CChar((self >> 24) & 0xff),
            CChar((self >> 16) & 0xff),
            CChar((self >> 8) & 0xff),
            CChar(self & 0xff),
            0
        ]
        let result = String(cString: bytes)
        let characterSet = CharacterSet.whitespaces
        return result.trimmingCharacters(in: characterSet)
    }
}

infix operator <> : DefaultPrecedence
extension AudioFormatFlags {
    
    static func <> (left: AudioFormatFlags, right: AudioFormatFlags) -> Bool {
        (left & right) != 0
    }
}

extension AudioStreamBasicDescription {
    
    var pcmFormatDescription: String {
        
        var formatStr: String = "PCM "
        
        let bitDepth: UInt32 = mBitsPerChannel
        let isFloat: Bool = mFormatFlags <> kAudioFormatFlagIsFloat
        let isSignedInt: Bool = mFormatFlags <> kAudioFormatFlagIsSignedInteger
        let isBigEndian: Bool = mFormatFlags <> kAudioFormatFlagIsBigEndian
        
        formatStr += isFloat ? "\(bitDepth)-bit float " : (isSignedInt ? "signed \(bitDepth)-bit " : "unsigned \(bitDepth)-bit ")
        
        formatStr += isBigEndian ? "(big-endian)" : "(little-endian)"
        
        return formatStr
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

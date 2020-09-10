import Foundation

protocol FFMpegMetadataParser {
    
    func mapTrack(_ meta: FFmpegMetadataReaderContext)
    
    func hasMetadataForTrack(_ meta: FFmpegMetadataReaderContext) -> Bool
    
    func getTitle(_ meta: FFmpegMetadataReaderContext) -> String?
    
    func getArtist(_ meta: FFmpegMetadataReaderContext) -> String?
    
    func getAlbum(_ meta: FFmpegMetadataReaderContext) -> String?
    
    func getGenre(_ meta: FFmpegMetadataReaderContext) -> String?
    
    func getLyrics(_ meta: FFmpegMetadataReaderContext) -> String?
    
    func getDiscNumber(_ meta: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)?
    
    func getTotalDiscs(_ meta: FFmpegMetadataReaderContext) -> Int?
    
    func getTrackNumber(_ meta: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)?
    
    func getTotalTracks(_ meta: FFmpegMetadataReaderContext) -> Int?
    
    func getYear(_ meta: FFmpegMetadataReaderContext) -> Int?
    
    func getDuration(_ meta: FFmpegMetadataReaderContext) -> Double?
    
//    func getGenericMetadata(_ meta: FFmpegMetadataReaderContext) -> [String: String]
}

extension FFMpegMetadataParser {
    
    func getTitle(_ meta: FFmpegMetadataReaderContext) -> String? {
        return nil
    }
    
    func getArtist(_ meta: FFmpegMetadataReaderContext) -> String? {
        return nil
    }
    
    func getAlbum(_ meta: FFmpegMetadataReaderContext) -> String? {
        return nil
    }
    
    func getGenre(_ meta: FFmpegMetadataReaderContext) -> String? {
        return nil
    }
    
    func getLyrics(_ meta: FFmpegMetadataReaderContext) -> String? {
        return nil
    }
    
    func getDiscNumber(_ meta: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
        return nil
    }
    
    func getTotalDiscs(_ meta: FFmpegMetadataReaderContext) -> Int? {
        return nil
    }
    
    func getTrackNumber(_ meta: FFmpegMetadataReaderContext) -> (number: Int?, total: Int?)? {
        return nil
    }
    
    func getTotalTracks(_ meta: FFmpegMetadataReaderContext) -> Int? {
        return nil
    }
 
    func getDuration(_ meta: FFmpegMetadataReaderContext) -> Double? {
        return nil
    }
}

class FFmpegMetadataReaderContext {
    
    let fileCtx: FFmpegFileContext
    let fileType: String
    
    let audioStream: FFmpegAudioStream?
    let imageStream: FFmpegImageStream?
    
    var map: [String: String] = [:]
    
    let commonMetadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    let id3Metadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    let wmMetadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    let vorbisMetadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    let apeMetadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    let otherMetadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    
    init(for fileCtx: FFmpegFileContext) {
        
        self.fileCtx = fileCtx
        self.fileType = fileCtx.file.pathExtension.lowercased()
        
        self.audioStream = fileCtx.bestAudioStream
        self.imageStream = fileCtx.bestImageStream

        for (key, value) in fileCtx.metadata {
            map[key] = value
        }
        
        for (key, value) in audioStream?.metadata ?? [:] {
            map[key] = value
        }
    }
}

class FFmpegParserMetadataMap {
    
    var essentialFields: [String: String] = [:]
    var genericFields: [String: String] = [:]
}

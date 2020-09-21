import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    static var play: Bool = false
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var visualizer: Visualizer!
    
    private var file: URL = URL(fileURLWithPath: "/Volumes/MyData/Music/01-06- Jacqueline (Chill Mix).mp3")
    //    private var file: URL = URL(fileURLWithPath: "/Volumes/MyData/Music/Album/Billie Jean.mp3")
    //    private var file: URL = URL(fileURLWithPath: "/Volumes/MyData/Music/0Music for inner stillness/Karitas.mp3")
    //    private var file: URL = URL(fileURLWithPath: "/Volumes/MyData/Music/VTA2/4-06 The Theme.mp3")
    
    private let player = Player()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if Self.play {
            
            player.outputRenderObserver = visualizer
            
            player.play(file: file)
            player.seekToTime(seconds: 40)
            
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

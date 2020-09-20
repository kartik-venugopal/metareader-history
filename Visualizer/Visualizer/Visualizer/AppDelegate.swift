import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var sp: SKVizView!
    
    private var file: URL = URL(fileURLWithPath: "/Volumes/MyData/Music/01-06- Jacqueline (Chill Mix).mp3")
//    private var file: URL = URL(fileURLWithPath: "/Volumes/MyData/Music/Album/Billie Jean.mp3")
//    private var file: URL = URL(fileURLWithPath: "/Volumes/MyData/Music/0Music for inner stillness/Karitas.mp3")
//    private var file: URL = URL(fileURLWithPath: "/Volumes/MyData/Music/goingToSanFran.mp3")
    
    private let player = Player()
    lazy var viz: Visualizer = Visualizer(sp: sp)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        player.outputRenderObserver = viz
        
        player.play(file: file)
        player.seekToTime(seconds: 40)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

import Cocoa

class PlaylistVC: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    override var nibName: String? {return "Playlist"}
    
    static var instance: PlaylistVC!
    
    private let playlist: Playlist = Playlist.instance
    
    @IBOutlet weak var table: NSTableView!
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "tracksAdded"), object: nil, queue: nil, using: {notif in
            
            DispatchQueue.main.async {
                self.updateSummary()
            }
        })
        
        Self.instance = self
    }
    
    func updateSummary() {
        
        self.table.noteNumberOfRowsChanged()
        self.lblTracksSummary.stringValue = "\(self.playlist.size) track(s)"
        self.lblDurationSummary.stringValue = "\(secsToHMS(Int(round(self.playlist.duration))))"
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        playlist.size
    }
    
    func clear() {
        table.reloadData()
        updateSummary()
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = playlist.trackAtIndex(row), let columnId = tableColumn?.identifier else {return nil}
        
        switch columnId.rawValue {
            
        case "index":
            
            // Otherwise, create a text cell with the track index
            return createTextCell(tableView, "index", String(describing: row + 1))
            
        case "art":
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "art"), owner: nil) as? NSTableCellView {
                
                cell.imageView?.image = track.art
                return cell
            }
            
        case "title":
            
            return createTextCell(tableView, "title", track.title ?? track.defaultDisplayName)
            
        case "artist":

            if let artist = track.artist {
                return createTextCell(tableView, "artist", artist)
            }

        case "album":

            if let album = track.album {
                return createTextCell(tableView, "album", album)
            }

        case "genre":

            if let genre = track.genre {
                return createTextCell(tableView, "genre", genre)
            }

        case "trackNum":

            if let trackNum = track.displayedTrackNum {
                return createTextCell(tableView, "trackNum", trackNum)
            }

        case "discNum":

            if let discNum = track.displayedDiscNum {
                return createTextCell(tableView, "discNum", discNum)
            }
            
        case "year":

            if let year = track.year {
                return createTextCell(tableView, "year", "\(year)")
            }
            
        case "duration":
            
            return createTextCell(tableView, "duration", secsToHMS(Int(round(track.duration))))
            
        default:
            
            return nil // Impossible
        }
        
        return nil
    }

    private func createTextCell(_ tableView: NSTableView, _ id: String, _ text: String) -> NSTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: nil) as? NSTableCellView else {return nil}
        cell.textField?.stringValue = text
        return cell
    }
}

func secsToHMS(_ absSecs: Int) -> String {
    
    let secs = absSecs % 60
    let mins = (absSecs / 60) % 60
    let hrs = absSecs / 3600
    
    return hrs > 0 ? String(format: "%d:%02d:%02d", hrs, mins, secs) : String(format: "%d:%02d", mins, secs)
}

//
//  AppDelegate.swift
//  MetaRead
//
//  Created by Kven on 9/8/20.
//  Copyright © 2020 Kven. All rights reserved.
//

import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let playlist: Playlist = Playlist.instance

    var dialog: NSOpenPanel = {
        
        let dialog = NSOpenPanel()
        
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = true
        
        dialog.canChooseDirectories    = true
        
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = true
        
        dialog.resolvesAliases = true;
        
        dialog.directoryURL = URL(fileURLWithPath: NSHomeDirectory() + "/Music/Aural-Test")
        
        return dialog
    }()

    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var label: NSTextField!
    
    lazy var playlistVC: PlaylistVC = PlaylistVC()
    
    @IBAction func openAction(_ sender: Any) {
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            
            clearAction(self)
            
            playlist.addFiles(dialog.urls)
            label.stringValue = dialog.urls.map {$0.path}.joined(separator: " | ")
        }
    }
    
    @IBAction func clearAction(_ sender: Any) {
        
        playlist.clear()
        label.stringValue = ""
        PlaylistVC.instance.clear()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        freopen(URL(fileURLWithPath: "/Volumes/MyData/Music/Aural-Test/metaRead.log").path.cString(using: String.Encoding.ascii)!, "a+", stderr)
        
        window.contentView?.addSubview(playlistVC.view)
        
//        let arr: [String] = ["sf2", "ghi", "75", "sdfsdf", "66"]
//        let firstInt: Int? = arr.lazy.compactMap {
//
//            print("Trying \($0)\n")
//            return Int($0)
//
//        }.first
//
//        print("--------")
//
//        print("\nResult: \(firstInt)")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}


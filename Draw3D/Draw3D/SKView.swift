//
//  SKView.swift
//  Draw3D
//
//  Created by Kven on 9/19/20.
//  Copyright © 2020 Kven. All rights reserved.
//

import Foundation
import SceneKit

class SKView: SCNView {
    
    var bar: SCNBox!
    var barNode: SCNNode!
    
    var cameraNode: SCNNode!
    var camera: SCNCamera!
    
    var floorNode: SCNNode!
    var floor: SCNFloor!
    
    let piOver180: CGFloat = CGFloat.pi / 180
    
    var px: CGFloat = 0
    var py: CGFloat = 2
    var pz: CGFloat = 0
    
    var ax: CGFloat = 0
    var ay: CGFloat = 0
    var az: CGFloat = 0
    
    @IBOutlet weak var pxVal: NSStepper!
    @IBOutlet weak var pyVal: NSStepper!
    @IBOutlet weak var pzVal: NSStepper!
    
    @IBOutlet weak var pxLbl: NSTextField!
    @IBOutlet weak var pyLbl: NSTextField!
    @IBOutlet weak var pzLbl: NSTextField!
    
    @IBOutlet weak var axVal: NSStepper!
    @IBOutlet weak var ayVal: NSStepper!
    @IBOutlet weak var azVal: NSStepper!
    
    @IBOutlet weak var axLbl: NSTextField!
    @IBOutlet weak var ayLbl: NSTextField!
    @IBOutlet weak var azLbl: NSTextField!
    
    @IBAction func pxAction(_ sender: Any) {
        
        px = CGFloat(pxVal.floatValue)
        cameraNode.position = SCNVector3(x: px, y: py, z: pz)
        pxLbl.stringValue = "\(px)"
    }
    
    @IBAction func pyAction(_ sender: Any) {
        
        py = CGFloat(pyVal.floatValue)
        cameraNode.position = SCNVector3(x: px, y: py, z: pz)
        pyLbl.stringValue = "\(py)"
    }
    
    @IBAction func pzAction(_ sender: Any) {
        
        pz = CGFloat(pzVal.floatValue)
        cameraNode.position = SCNVector3(x: px, y: py, z: pz)
        pzLbl.stringValue = "\(pz)"
    }
    
    @IBAction func axAction(_ sender: Any) {
        
        ax = CGFloat(axVal.floatValue)
        cameraNode.eulerAngles = SCNVector3(x: ax * piOver180, y: ay * piOver180, z: az * piOver180)
        axLbl.stringValue = "\(ax)"
    }
    
    @IBAction func ayAction(_ sender: Any) {
        
        ay = CGFloat(ayVal.floatValue)
        cameraNode.eulerAngles = SCNVector3(x: ax * piOver180, y: ay * piOver180, z: az * piOver180)
        ayLbl.stringValue = "\(ay)"
    }
    
    @IBAction func azAction(_ sender: Any) {
        
        az = CGFloat(azVal.floatValue)
        cameraNode.eulerAngles = SCNVector3(x: ax * piOver180, y: ay * piOver180, z: az * piOver180)
        azLbl.stringValue = "\(az)"
    }
    
    override func awakeFromNib() {
        
        scene = SCNScene()
        scene?.background.contents = NSColor.black
        
        // MARK: Camera ---------------------------------------

        camera = SCNCamera()
        cameraNode = SCNNode()
        
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: px, y: py, z: pz)
//        cameraNode.eulerAngles = SCNVector3(x: ax * piOver180, y: ay * piOver180, z: az * piOver180)
        cameraNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w: 15 * piOver180)
        
        cameraNode.position = SCNVector3(x: 3.5, y: 1.7, z: 3)
        
//        pxVal.floatValue = Float(px * 10)
//        pyVal.floatValue = Float(py * 10)
//        pzVal.floatValue = Float(pz * 10)
//
//        axVal.floatValue = Float(ax)
//        ayVal.floatValue = Float(ay)
//        azVal.floatValue = Float(az)
//
//        pxAction(self)
//        pyAction(self)
//        pzAction(self)
//
//        axAction(self)
//        ayAction(self)
//        azAction(self)
        
        scene!.rootNode.addChildNode(cameraNode)
        
        // MARK: Bar ---------------------------------------

        self.bar = SCNBox(width: 0.15, height: 2, length: 0.15, chamferRadius: 0.02)
        self.barNode = SCNNode(geometry: bar)
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = [NSColor.green.cgColor, NSColor.green.interpolate(NSColor.red, bar.height / 4).cgColor]
        gradientLayer.frame = NSRect(x: 0, y: 0, width: 20, height: 100)
        
        bar.firstMaterial?.diffuse.contents = gradientLayer
        
        scene!.rootNode.addChildNode(barNode)
        
        // MARK: Floor ---------------------------------------

        floor = SCNFloor()
        floor.reflectionCategoryBitMask = 4
        floor.firstMaterial?.diffuse.contents = NSColor.black
        floor.firstMaterial?.lightingModel = .lambert
        
        floorNode = SCNNode(geometry: floor)
        scene!.rootNode.addChildNode(floorNode)
        
        SCNTransaction.begin()
        barNode.position = SCNVector3(0, -1, 0)
        barNode.pivot = SCNMatrix4MakeTranslation(0, -(bar.height / 2), 0) // new height
        SCNTransaction.commit()
        
        // MARK: Scene settings ---------------------------------------
        antialiasingMode = .multisampling4X
        isJitteringEnabled = true
        allowsCameraControl = true
        autoenablesDefaultLighting = true
        showsStatistics = false
    }
    
    var expand: Bool = false
    var beaten: Bool = false
    
    func beat() {
        
        expand.toggle()
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.2
        
        if expand {
            bar.height = bar.height * 2
        } else {
            bar.height = bar.height / 2
        }
        
        barNode.pivot = SCNMatrix4MakeTranslation(0, -(bar.height / 2), 0) // new height
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
                gradientLayer.colors = [NSColor.green.cgColor, NSColor.green.interpolate(NSColor.red, bar.height / 4).cgColor]
                gradientLayer.frame = NSRect(x: 0, y: 0, width: 20, height: 100)
                
        //        bar.firstMaterial?.diffuse.contents  = NSColor(red: 30.0 / 255.0, green: 180.0 / 255.0, blue: 30.0 / 255.0, alpha: 1)
                bar.firstMaterial?.diffuse.contents = gradientLayer
            
        SCNTransaction.commit()
        
        beaten = true
    }
}

extension NSColor{
    /**
     * Interpolates between two NSColors
     * EXAMPLE: NSColor.green.interpolate(.blue, 0.5)
     * NOTE: There is also a native alternative: NSColor.green.blended(withFraction: 0.5, of: .blue)
     */
    func interpolate(_ to:NSColor,_ scalar:CGFloat)->NSColor{
        func interpolate(_ start:CGFloat,_ end:CGFloat,_ scalar:CGFloat)->CGFloat{
            return start + (end - start) * scalar
        }
        let fromRGBColor:NSColor = self.usingColorSpace(.genericRGB)!
        let toRGBColor:NSColor = to.usingColorSpace(.genericRGB)!
        let red:CGFloat = interpolate(fromRGBColor.redComponent, toRGBColor.redComponent,scalar)
        let green:CGFloat = interpolate(fromRGBColor.greenComponent, toRGBColor.greenComponent,scalar)
        let blue:CGFloat = interpolate(fromRGBColor.blueComponent, toRGBColor.blueComponent,scalar)
        let alpha:CGFloat = interpolate(fromRGBColor.alphaComponent, toRGBColor.alphaComponent,scalar)
        return NSColor.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

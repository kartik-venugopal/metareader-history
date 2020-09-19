//
//  Ball.swift
//  Pool
//
//  Created by Kay Ven on 8/5/17.
//  Copyright © 2017 anon. All rights reserved.
//

import SceneKit
import Foundation

class Ball {
    
    var number: Int
    var pocketed: Bool
//    var type: BallType
    
    init(_ number: Int) {
        self.number = number
        self.pocketed = false
        
//        if (number == 0) {
//            self.type = .cue
//        } else if (number == 8) {
//            self.type = .eight
//        } else if (number < 8) {
//            self.type = .solid
//        } else {
//            self.type = .stripe
//        }
    }
}

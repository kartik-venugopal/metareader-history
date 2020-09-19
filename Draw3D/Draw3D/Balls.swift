//
//  Balls.swift
//  Pool
//
//  Created by Kay Ven on 8/5/17.
//  Copyright © 2017 anon. All rights reserved.
//

import Foundation

class Balls {
    
    private static let singleton = Balls()
    
    var balls: [Ball]
    
    init() {
        
        balls = [Ball]()
        
//        for i in 1...15 {
//            balls.append(Ball(i, Constants.tableCenter))
//        }
        
        rack()
    }
    
    func rack() {
        
//        let radius = Constants.ballRadius
//        let diameter = 2 * radius
//        let dz = Constants.rack_dz
////        
//        balls.append(Ball(0, BallVector(0, -10)))
//        
//        balls.append(Ball(1, BallVector(diameter, 0)))
//        balls.append(Ball(2, BallVector(-diameter, 2 * dz)))
//        balls.append(Ball(3, BallVector(radius, dz)))
//        balls.append(Ball(4, BallVector(diameter, 2 * dz)))
//        balls.append(Ball(5, BallVector(2 * diameter, 2 * dz)))
//        balls.append(Ball(6, BallVector(-1.5 * diameter, 1 * dz)))
//        balls.append(Ball(7, BallVector(-0.5 * diameter, -dz)))
//        balls.append(Ball(8, BallVector(0, 0)))
//        balls.append(Ball(9, BallVector(0, -2 * dz)))
//        balls.append(Ball(10, BallVector(-0.5 * diameter, dz)))
//        balls.append(Ball(11, BallVector(-2 * diameter, 2 * dz)))
//        balls.append(Ball(12, BallVector(0.5 * diameter, -dz)))
//        balls.append(Ball(13, BallVector(0, 2 * dz)))
//        balls.append(Ball(14, BallVector(1.5 * diameter, 1 * dz)))
//        balls.append(Ball(15, BallVector(-diameter, 0)))
//        
//        balls[1].position = BallVector(diameter, 0)
//        balls[2].position = BallVector(-diameter, 2 * dz)
//        balls[3].position = BallVector(radius, dz)
//        balls[4].position = BallVector(diameter, 2 * dz)
//        balls[5].position = BallVector(2 * diameter, 2 * dz)
//        balls[6].position = BallVector(-1.5 * diameter, 1 * dz)
//        balls[7].position = BallVector(-0.5 * diameter, -dz)
//        balls[8].position = BallVector(0, 0)
//        balls[9].position = BallVector(0, -2 * dz)
//        balls[10].position = BallVector(-0.5 * diameter, dz)
//        balls[11].position = BallVector(-2 * diameter, 2 * dz)
//        balls[12].position = BallVector(0.5 * diameter, -dz)
//        balls[13].position = BallVector(0, 2 * dz)
//        balls[14].position = BallVector(1.5 * diameter, 1 * dz)
//        balls[15].position = BallVector(-diameter, 0)
    }
    
    static func instance() -> Balls {
        return singleton
    }
    
    func get(_ index: Int) -> Ball {
        return balls[index]
    }
}

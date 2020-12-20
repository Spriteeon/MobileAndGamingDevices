//
//  GameScene.swift
//  MobileAndGamingDevices
//
//  Created by COWARD, MALACHI (Student) on 20/12/2020.
//  Copyright © 2020 COWARD, MALACHI (Student). All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var playerCar = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        setUp()
        createRoadStrips()
    }
    
    override func update(_ currentTime: TimeInterval) {
        showRoadStrips()
    }
    
    func setUp() {
        playerCar = self.childNode(withName: "playerCar") as! SKSpriteNode
    }
    
    func createRoadStrips() {
        let leftRoadStrip = SKShapeNode(rectOf : CGSize(width: 10, height: 40))
        leftRoadStrip.strokeColor = SKColor.white
        leftRoadStrip.fillColor = SKColor.white
        leftRoadStrip.alpha = 0.4
        leftRoadStrip.name = "roadStrip"
        leftRoadStrip.zPosition = 10
        leftRoadStrip.position.x = -187.5
        leftRoadStrip.position.y = 600
        addChild(leftRoadStrip)
        
        let middleRoadStrip = SKShapeNode(rectOf : CGSize(width: 10, height: 40))
        middleRoadStrip.strokeColor = SKColor.white
        middleRoadStrip.fillColor = SKColor.white
        middleRoadStrip.alpha = 0.4
        middleRoadStrip.name = "roadStrip"
        middleRoadStrip.zPosition = 10
        middleRoadStrip.position.x = 187.5
        middleRoadStrip.position.y = 600
        addChild(middleRoadStrip)
        
        let rightRoadStrip = SKShapeNode(rectOf : CGSize(width: 10, height: 40))
        rightRoadStrip.strokeColor = SKColor.white
        rightRoadStrip.fillColor = SKColor.white
        rightRoadStrip.alpha = 0.4
        rightRoadStrip.name = "roadStrip"
        rightRoadStrip.zPosition = 10
        rightRoadStrip.position.x = 0
        rightRoadStrip.position.y = 600
        addChild(rightRoadStrip)
    }
    
    func showRoadStrips() {
        
    }
    
}

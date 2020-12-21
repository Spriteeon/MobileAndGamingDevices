//
//  GameScene.swift
//  MobileAndGamingDevices
//
//  Created by COWARD, MALACHI (Student) on 20/12/2020.
//  Copyright © 2020 COWARD, MALACHI (Student). All rights reserved.
//

import CoreMotion
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    
    var leftWall = SKSpriteNode()
    var rightWall = SKSpriteNode()
    var topWall = SKSpriteNode()
    var bottomWall = SKSpriteNode()
    
    // Hack stuff for using Sim
    var lastTouchPosition: CGPoint?
    var motionManager: CMMotionManager?
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        createGame()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
    
    override func update(_ currentTime: TimeInterval) {
        showRoadStrips()
        showEnemyCars()
        removeItems()
        
        move()
    }
    
    func createGame() {
        createPlayer()
        createWalls()
        Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector (GameScene.createRoadStrips), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 2)), target: self, selector: #selector (GameScene.leftTraffic), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 2)), target: self, selector: #selector (GameScene.rightTraffic), userInfo: nil, repeats: true)
    }
    
    func move() {
        #if targetEnvironment(simulator)
        if let lastTouchPosition = lastTouchPosition {
            let diff = CGPoint(x: lastTouchPosition.x - player.position.x, y: lastTouchPosition.y - player.position.y)
            physicsWorld.gravity = CGVector(dx: diff.x / 200, dy: diff.y / 200)
        }
        #else
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.x * 50, dy: accelerometerData.acceleration.y * -50)
        }
        #endif
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "playerCar")
        player.position = CGPoint(x: -70, y: -300)
        player.zPosition = 50
        
        // Do Player Physics stuff here
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        
        addChild(player)
    }
    
    func createWalls() {
        leftWall = self.childNode(withName: "leftWall") as! SKSpriteNode
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
        leftWall.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        leftWall.physicsBody?.isDynamic = false
        
        rightWall = self.childNode(withName: "rightWall") as! SKSpriteNode
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
        rightWall.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        rightWall.physicsBody?.isDynamic = false
        
        topWall = self.childNode(withName: "topWall") as! SKSpriteNode
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        topWall.physicsBody?.isDynamic = false
        
        bottomWall = self.childNode(withName: "bottomWall") as! SKSpriteNode
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        bottomWall.physicsBody?.isDynamic = false
        
    }
    
    @objc func createRoadStrips() {
        let leftRoadStrip = SKShapeNode(rectOf : CGSize(width: 10, height: 40))
        leftRoadStrip.strokeColor = SKColor.white
        leftRoadStrip.fillColor = SKColor.white
        leftRoadStrip.alpha = 0.4
        leftRoadStrip.name = "leftRoadStrip"
        leftRoadStrip.zPosition = 10
        leftRoadStrip.position.x = -(frame.size.width/4) + 25
        leftRoadStrip.position.y = 600
        addChild(leftRoadStrip)
        
        let middleRoadStrip = SKShapeNode(rectOf : CGSize(width: 10, height: 40))
        middleRoadStrip.strokeColor = SKColor.white
        middleRoadStrip.fillColor = SKColor.white
        middleRoadStrip.alpha = 0.4
        middleRoadStrip.name = "middleRoadStrip"
        middleRoadStrip.zPosition = 10
        middleRoadStrip.position.x = self.frame.midX
        middleRoadStrip.position.y = 600
        addChild(middleRoadStrip)
        
        let rightRoadStrip = SKShapeNode(rectOf : CGSize(width: 10, height: 40))
        rightRoadStrip.strokeColor = SKColor.white
        rightRoadStrip.fillColor = SKColor.white
        rightRoadStrip.alpha = 0.4
        rightRoadStrip.name = "rightRoadStrip"
        rightRoadStrip.zPosition = 10
        rightRoadStrip.position.x = (frame.size.width/4) - 25
        rightRoadStrip.position.y = 600
        addChild(rightRoadStrip)
    }
    
    func showRoadStrips() {
        
        enumerateChildNodes(withName: "leftRoadStrip", using: { (roadStrip, stop) in
            let strip = roadStrip as! SKShapeNode
            strip.position.y -= 30
        })
        enumerateChildNodes(withName: "middleRoadStrip", using: { (roadStrip, stop) in
            let strip = roadStrip as! SKShapeNode
            strip.position.y -= 30
        })
        enumerateChildNodes(withName: "rightRoadStrip", using: { (roadStrip, stop) in
            let strip = roadStrip as! SKShapeNode
            strip.position.y -= 30
        })
    }
    
    func showEnemyCars() {
        
        enumerateChildNodes(withName: "enemyCar", using: { (car, stop) in
            let currentCar = car as! SKSpriteNode
            currentCar.position.y -= 10
        })
    }
    
    @objc func leftTraffic() {
        let trafficItem : SKSpriteNode!
        let randomCol = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 8)
        switch Int(randomCol) {
        case 1...4:
            trafficItem = SKSpriteNode(imageNamed: "orangeCar")
            trafficItem.name = "enemyCar"
            break
        case 5...8:
            trafficItem = SKSpriteNode(imageNamed: "greenCar")
            trafficItem.name = "enemyCar"
            break
        default:
            // Should never happen
            trafficItem = SKSpriteNode(imageNamed: "blueCar")
            trafficItem.name = "enemyCar"
        }
        trafficItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        trafficItem.zPosition = 50
        
        let randomLane = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 8)
        switch randomLane {
        case 1...4: // Far Left Lane
            trafficItem.position.x = -(frame.size.width/4) - 60
            break
        case 5...8: // Middle Left Lane
            trafficItem.position.x = -(frame.size.width/4) + 110
            break
        default:
            // Should never happen
            trafficItem.position.x = -(frame.size.width/4) - 60
        }
        trafficItem.position.y = self.frame.maxY + 100
    
        trafficItem.physicsBody = SKPhysicsBody(rectangleOf: trafficItem.size)
        trafficItem.physicsBody?.isDynamic = false

        trafficItem.physicsBody?.categoryBitMask = CollisionTypes.enemy.rawValue
        trafficItem.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        trafficItem.physicsBody?.collisionBitMask = 0
        
        addChild(trafficItem)
    }
    
    @objc func rightTraffic() {
        let trafficItem : SKSpriteNode!
        let randomCol = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 8)
        switch Int(randomCol) {
        case 1...4:
            trafficItem = SKSpriteNode(imageNamed: "orangeCar")
            trafficItem.name = "enemyCar"
            break
        case 5...8:
            trafficItem = SKSpriteNode(imageNamed: "greenCar")
            trafficItem.name = "enemyCar"
            break
        default:
            // Should never happen
            trafficItem = SKSpriteNode(imageNamed: "blueCar")
            trafficItem.name = "enemyCar"
        }
        trafficItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        trafficItem.zPosition = 50
        
        let randomLane = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 8)
        switch randomLane {
        case 1...4: // Middle Right Lane
            trafficItem.position.x = (frame.size.width/4) - 110
            break
        case 5...8: // Far Right Lane
            trafficItem.position.x = (frame.size.width/4) + 60
            break
        default:
            // Should never happen
            trafficItem.position.x = (frame.size.width/4) + 60
        }
        trafficItem.position.y = self.frame.maxY + 100
        
        trafficItem.physicsBody = SKPhysicsBody(rectangleOf: trafficItem.size)
        trafficItem.physicsBody?.isDynamic = false

        trafficItem.physicsBody?.categoryBitMask = CollisionTypes.enemy.rawValue
        trafficItem.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        trafficItem.physicsBody?.collisionBitMask = 0
        
        addChild(trafficItem)
    }
    
    func removeItems() {
        for child in children{
            if child.position.y < -self.size.height - 100{
                child.removeFromParent()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Hack Stuff
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Hack Stuff
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Hack Stuff
        lastTouchPosition = nil
    }
    
}

//
//  GameScene.swift
//  MobileAndGamingDevices
//
//  Created by COWARD, MALACHI (Student) on 20/12/2020.
//  Copyright © 2020 COWARD, MALACHI (Student). All rights reserved.
//

import CoreMotion
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var syringeNode: SKSpriteNode!
    var trafficItem: SKSpriteNode!
    var road: SKSpriteNode!
    
    // Hack stuff for using Sim
    var lastTouchPosition: CGPoint?
    var motionManager: CMMotionManager?
    
    var leftRoadMarkingXPosition: CGFloat!
    var middleRoadMarkingXPosition: CGFloat!
    var rightRoadMarkingXPosition: CGFloat!
    
    var farLeftTrafficXPosition: CGFloat!
    var leftMiddleTrafficXPosition: CGFloat!
    var rightMiddleTrafficXPosition: CGFloat!
    var farRightTrafficXPosition: CGFloat!
    
    var carWidth: CGFloat!
    var carHeight: CGFloat!
    
    var roadStripWidth: CGFloat!
    var roadStripHeight: CGFloat!
    
    var syringeWidth: CGFloat!
    var syringeHeight: CGFloat!
    
    var canFire: Bool!
    var count: Int!
    
    let scoreLabel = SKLabelNode(text: "0")
    var score = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    let livesLabel = SKLabelNode(text: "5")
    var lives = 3 {
        didSet {
            livesLabel.text = "\(lives)"
        }
    }
    
    var isGameOver = false
    
    var possibleCars = ["orangeCar", "greenCar", "blueCar"]
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        createGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        guard isGameOver == false else { return }
        
        count += 1
        if count > 30 {
            canFire = true
        } else {
            canFire = false
        }
        
        showRoadStrips()
        showEnemyCars()
        showScenery()
        showSyringes()
        removeItems()
        
        move()
        
        score += 1
        
        if lives <= 0 {
            gameOver()
        }
    }
    
    func move() {
        #if targetEnvironment(simulator)
        if let lastTouchPosition = lastTouchPosition {
            let diff = CGPoint(x: lastTouchPosition.x - player.position.x, y: lastTouchPosition.y - player.position.y)
            player.physicsBody?.velocity = CGVector(dx: diff.x, dy: diff.y)
        }
        #else
        if let accelerometerData = motionManager?.accelerometerData {
            player.physicsBody?.velocity = CGVector(dx: accelerometerData.acceleration.x * 50, dy: accelerometerData.acceleration.y * -50)
        }
        #endif
    }
    
    func createGame() {
        
        canFire = true
        count = 0
        
        carWidth = self.frame.width / 10
        carHeight = self.frame.height / 10
        
        syringeWidth = carWidth / 4
        syringeHeight = carHeight / 2
        
        roadStripWidth = self.frame.width / 70
        roadStripHeight = self.frame.height / 30
        
        leftRoadMarkingXPosition = -(self.frame.size.width/4) + 25
        middleRoadMarkingXPosition = self.frame.midX
        rightRoadMarkingXPosition = (self.frame.size.width/4) - 25
        
        farLeftTrafficXPosition = (leftRoadMarkingXPosition + (self.frame.minX + 25)) / 2
        leftMiddleTrafficXPosition = (leftRoadMarkingXPosition + middleRoadMarkingXPosition) / 2
        rightMiddleTrafficXPosition = (rightRoadMarkingXPosition + middleRoadMarkingXPosition) / 2
        farRightTrafficXPosition = (rightRoadMarkingXPosition + (self.frame.maxX - 25)) / 2
        
        createPlayer()
        createWalls()
        addUI()
        
        //createBackground()
        
        Timer.scheduledTimer(timeInterval: TimeInterval(0.2), target: self, selector: #selector (GameScene.createRoadStrips), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 3)), target: self, selector: #selector (GameScene.leftTraffic), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 3)), target: self, selector: #selector (GameScene.rightTraffic), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector (GameScene.createScenery), userInfo: nil, repeats: true)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
        
    }
    
    func gameOver() {
        isGameOver = true
        physicsWorld.gravity = .zero
        
        UserDefaults.standard.set(score, forKey: "RecentScore")
        if score > UserDefaults.standard.integer(forKey: "Highscore") {
            UserDefaults.standard.set(score, forKey: "Highscore")
        }
        
        let loseMenuScene = LoseMenuScene(size: view!.bounds.size)
        view!.presentScene(loseMenuScene)
    }
    
    /*func createBackground() {
        road = SKSpriteNode(imageNamed: "RoadBackground")
        road.size = self.size
        road.position = CGPoint(x: 0, y: 0)
        road.zPosition = 0
        addChild(road)
    }*/
    
    func addUI() {
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 60.0
        scoreLabel.fontColor = UIColor.red
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
        
        livesLabel.fontName = "AvenirNext-Bold"
        livesLabel.fontSize = 60.0
        livesLabel.fontColor = UIColor.red
        livesLabel.position = CGPoint(x: frame.maxX - 25, y: frame.maxY - 100)
        livesLabel.zPosition = 100
        addChild(livesLabel)
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "ambulance")
        player.size.width = carWidth
        player.size.height = carHeight
        player.position = CGPoint(x: -70, y: -300)
        player.zPosition = 50
        
        // Do Player Physics stuff here
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.isDynamic = true
        player.physicsBody?.linearDamping = 0.5
        
        player.physicsBody?.contactTestBitMask = CollisionTypes.enemy.rawValue
        // player.physicsBody?.collisionBitMask = 0
        
        addChild(player)
    }
    
    func createWalls() {
        let leftWall = SKShapeNode(rectOf : CGSize(width: 100, height: self.frame.height))
        leftWall.strokeColor = SKColor(red: 5/255, green: 112/255, blue: 28/255, alpha: 1)
        leftWall.fillColor = SKColor(red: 5/255, green: 112/255, blue: 28/255, alpha: 1)
        leftWall.alpha = 1
        leftWall.name = "leftWall"
        leftWall.zPosition = 10
        leftWall.position.x = self.frame.minX
        leftWall.position.y = self.frame.midY
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.frame.size)
        leftWall.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        addChild(leftWall)
        
        let rightWall = SKShapeNode(rectOf : CGSize(width: 100, height: self.frame.height))
        rightWall.strokeColor = SKColor(red: 5/255, green: 112/255, blue: 28/255, alpha: 1)
        rightWall.fillColor = SKColor(red: 5/255, green: 112/255, blue: 28/255, alpha: 1)
        rightWall.alpha = 1
        rightWall.name = "rightWall"
        rightWall.zPosition = 10
        rightWall.position.x = self.frame.maxX
        rightWall.position.y = self.frame.midY
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.frame.size)
        rightWall.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        addChild(rightWall)
        
        let topWall = SKShapeNode(rectOf : CGSize(width: self.frame.width, height: 50))
        topWall.strokeColor = SKColor(red: 5/255, green: 112/255, blue: 28/255, alpha: 1)
        topWall.fillColor = SKColor(red: 5/255, green: 112/255, blue: 28/255, alpha: 1)
        topWall.alpha = 1
        topWall.name = "topWall"
        topWall.zPosition = 10
        topWall.position.x = self.frame.midX
        topWall.position.y = self.frame.maxY + 25
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.frame.size)
        topWall.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        addChild(topWall)
        
        let bottomWall = SKShapeNode(rectOf : CGSize(width: self.frame.width, height: 50))
        bottomWall.strokeColor = SKColor(red: 5/255, green: 112/255, blue: 28/255, alpha: 1)
        bottomWall.fillColor = SKColor(red: 5/255, green: 112/255, blue: 28/255, alpha: 1)
        bottomWall.alpha = 1
        bottomWall.name = "bottomWall"
        bottomWall.zPosition = 10
        bottomWall.position.x = self.frame.midX
        bottomWall.position.y = self.frame.minY - 25
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.frame.size)
        bottomWall.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        bottomWall.physicsBody?.isDynamic = false
        bottomWall.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        addChild(bottomWall)
    }
    
    @objc func createScenery() {
        let treeItem = SKSpriteNode(imageNamed: "tree")
        
        treeItem.name = "tree"

        treeItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        treeItem.zPosition = 50
        
        let randomSide = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 8)
        switch randomSide {
        case 1...4: // Left Side
            treeItem.position.x = frame.minX
            break
        case 5...8: // Right Side
            treeItem.position.x = frame.maxX
            break
        default:
            // Should never happen
            treeItem.position.x = frame.minX
        }
        treeItem.position.y = self.frame.maxY + 100
        
        self.addChild(treeItem)
        
    }
    
    @objc func createRoadStrips() {
        let leftRoadStrip = SKShapeNode(rectOf : CGSize(width: roadStripWidth, height: roadStripHeight))
        leftRoadStrip.strokeColor = SKColor.white
        leftRoadStrip.fillColor = SKColor.white
        leftRoadStrip.alpha = 0.8
        leftRoadStrip.name = "leftRoadStrip"
        leftRoadStrip.zPosition = 10
        leftRoadStrip.position.x = leftRoadMarkingXPosition
        leftRoadStrip.position.y = self.frame.maxY + 50
        addChild(leftRoadStrip)
        
        let middleRoadStrip = SKShapeNode(rectOf : CGSize(width: roadStripWidth, height: roadStripHeight))
        middleRoadStrip.strokeColor = SKColor.white
        middleRoadStrip.fillColor = SKColor.white
        middleRoadStrip.alpha = 0.8
        middleRoadStrip.name = "middleRoadStrip"
        middleRoadStrip.zPosition = 10
        middleRoadStrip.position.x = middleRoadMarkingXPosition
        middleRoadStrip.position.y = self.frame.maxY + 50
        addChild(middleRoadStrip)
        
        let rightRoadStrip = SKShapeNode(rectOf : CGSize(width: roadStripWidth, height: roadStripHeight))
        rightRoadStrip.strokeColor = SKColor.white
        rightRoadStrip.fillColor = SKColor.white
        rightRoadStrip.alpha = 0.8
        rightRoadStrip.name = "rightRoadStrip"
        rightRoadStrip.zPosition = 10
        rightRoadStrip.position.x = rightRoadMarkingXPosition
        rightRoadStrip.position.y = self.frame.maxY + 50
        addChild(rightRoadStrip)
    }
    
    @objc func leftTraffic() {
        possibleCars = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleCars) as! [String]
        trafficItem = SKSpriteNode(imageNamed: possibleCars[0])
        trafficItem.name = "enemyCar"
        
        trafficItem.size.width = carWidth
        trafficItem.size.height = carHeight

        trafficItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        trafficItem.zPosition = 50
        
        let randomLane = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 8)
        switch randomLane {
        case 1...4: // Far Left Lane
            trafficItem.position.x = farLeftTrafficXPosition
            break
        case 5...8: // Middle Left Lane
            trafficItem.position.x = leftMiddleTrafficXPosition
            break
        default:
            // Should never happen
            trafficItem.position.x = farLeftTrafficXPosition
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
        possibleCars = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleCars) as! [String]
        trafficItem = SKSpriteNode(imageNamed: possibleCars[0])
        trafficItem.name = "enemyCar"
        
        trafficItem.size.width = carWidth
        trafficItem.size.height = carHeight
        
        trafficItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        trafficItem.zPosition = 50
        
        let randomLane = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 8)
        switch randomLane {
        case 1...4: // Middle Right Lane
            trafficItem.position.x = rightMiddleTrafficXPosition
            break
        case 5...8: // Far Right Lane
            trafficItem.position.x = farRightTrafficXPosition
            break
        default:
            // Should never happen
            trafficItem.position.x = farRightTrafficXPosition
        }
        trafficItem.position.y = self.frame.maxY + 100
        
        trafficItem.physicsBody = SKPhysicsBody(rectangleOf: trafficItem.size)
        trafficItem.physicsBody?.isDynamic = false

        trafficItem.physicsBody?.categoryBitMask = CollisionTypes.enemy.rawValue
        trafficItem.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        trafficItem.physicsBody?.collisionBitMask = 0
        
        self.addChild(trafficItem)
    }
    
    func fireSyringe() {
        
        guard canFire == true else { return }
        
        syringeNode = SKSpriteNode(imageNamed: "syringe")
        syringeNode.name = "syringe"
        syringeNode.size.width = syringeWidth
        syringeNode.size.height = syringeHeight
        syringeNode.position = player.position
        syringeNode.position.y += 100
        syringeNode.zPosition = 50
        
        syringeNode.physicsBody = SKPhysicsBody(rectangleOf: syringeNode.size)
        syringeNode.physicsBody?.isDynamic = true
        syringeNode.physicsBody?.allowsRotation = false
        //syringeNode.physicsBody?.usesPreciseCollisionDetection = true
        
        syringeNode.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        syringeNode.physicsBody?.contactTestBitMask = CollisionTypes.enemy.rawValue
        syringeNode.physicsBody?.collisionBitMask = 0
        
        self.addChild(syringeNode)
        // canFire = false
        count = 0
    }
    
    func removeItems() {
        for child in children{
            if child.position.y < -self.size.height - 100{
                child.removeFromParent()
            }
            if child.position.y > self.size.height + 150{
                child.removeFromParent()
            }
        }
    }
    
    func showScenery() {
        enumerateChildNodes(withName: "tree", using: { (tree, stop) in
            let treeItem = tree as! SKSpriteNode
            treeItem.position.y -= 30
        })
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
    
    func showSyringes() {
        
        enumerateChildNodes(withName: "syringe", using: { (syringe, stop) in
            let currentSyringe = syringe as! SKSpriteNode
            currentSyringe.position.y += 20
        })
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        } else if nodeA == syringeNode {
            syringeCollided(with: nodeB, syringe: nodeA)
        } else if nodeB == syringeNode {
            syringeCollided(with: nodeA, syringe: nodeB)
        }
    }
    
    func syringeCollided(with enemy: SKNode, syringe: SKNode) {
        
        score += 50
        
        enemy.removeFromParent()
        syringe.removeFromParent()
    }
    
    func playerCollided(with node: SKNode) {
        if node.name == "enemyCar" {
            node.removeFromParent()
            
            let explosion = SKEmitterNode(fileNamed: "Explosion")!
            explosion.position = node.position
            self.addChild(explosion)
            
            lives -= 1
            if lives <= 0 {
                gameOver()
            }
            
            self.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Hack Stuff
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
        
        fireSyringe()
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

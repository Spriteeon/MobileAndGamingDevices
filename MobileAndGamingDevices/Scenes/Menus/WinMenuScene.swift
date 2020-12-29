//
//  WinMenu.swift
//  MobileAndGamingDevices
//
//  Created by COWARD, MALACHI (Student) on 28/12/2020.
//  Copyright © 2020 COWARD, MALACHI (Student). All rights reserved.
//

import SpriteKit

// This Scene is Currently not in use as there is no Win Scenario at the moment
class WinMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        addLabels()
    }
    
    func addLabels() {
        
        // Win Label
        let titleLabel = SKLabelNode(text: "You Made it!")
        titleLabel.fontName = "AvenirNext-Bold"
        titleLabel.fontSize = 70.0
        titleLabel.fontColor = UIColor.white
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        addChild(titleLabel)
        
        // Animated Tap to Exit Label
        let playLabel = SKLabelNode(text: "Tap to Exit")
        playLabel.fontName = "AvenirNext-Bold"
        playLabel.fontSize = 50.0
        playLabel.fontColor = UIColor.white
        playLabel.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        addChild(playLabel)
        animate(label: playLabel)
        
        // Highscore Label updated from the Highscore
        let highscoreLabel = SKLabelNode(text: "Highscore: " + "\(UserDefaults.standard.integer(forKey: "Highscore"))")
        highscoreLabel.fontName = "AvenirNext-Bold"
        highscoreLabel.fontSize = 40.0
        highscoreLabel.fontColor = UIColor.white
        highscoreLabel.position = CGPoint(x: frame.midX, y: frame.midY - highscoreLabel.frame.size.height*4)
        addChild(highscoreLabel)
        
        // Recent Score Label updated from the Recent Score
        let recentScoreLabel = SKLabelNode(text: "Recent Score: " + "\(UserDefaults.standard.integer(forKey: "RecentScore"))")
        recentScoreLabel.fontName = "AvenirNext-Bold"
        recentScoreLabel.fontSize = 40.0
        recentScoreLabel.fontColor = UIColor.white
        recentScoreLabel.position = CGPoint(x: frame.midX, y: highscoreLabel.position.y - recentScoreLabel.frame.size.height*2)
        addChild(recentScoreLabel)
    }
    
    // Animation function for Tap to Exit Label
    func animate(label: SKLabelNode) {
        
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        label.run(SKAction.repeatForever(sequence))
    }
    
    // If Screen is touched then Main Menu will open
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        let mainMenuScene = MainMenuScene(size: view!.bounds.size)
        self.view?.presentScene(mainMenuScene, transition: transition)
    }

}

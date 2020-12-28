//
//  GameViewController.swift
//  MobileAndGamingDevices
//
//  Created by COWARD, MALACHI (Student) on 20/12/2020.
//  Copyright © 2020 COWARD, MALACHI (Student). All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView?, let scene = MainMenuScene(fileNamed: "MainMenuScene") {
            
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}

//
//  Settings.swift
//  MobileAndGamingDevices
//
//  Created by COWARD, MALACHI (Student) on 20/12/2020.
//  Copyright © 2020 COWARD, MALACHI (Student). All rights reserved.
//

import SpriteKit

enum PhysicsCategories {
    static let none: UInt32 = 0
    static let player: UInt32 = 0x1           // 01
    static let enemy: UInt32 = 0x1 << 1    // 10
}

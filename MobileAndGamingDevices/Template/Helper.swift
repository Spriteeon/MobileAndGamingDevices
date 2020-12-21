//
//  Helper.swift
//  MobileAndGamingDevices
//
//  Created by COWARD, MALACHI (Student) on 21/12/2020.
//  Copyright © 2020 COWARD, MALACHI (Student). All rights reserved.
//

import Foundation
import UIKit

class Helper : NSObject {
    
    func randomBetweenTwoNumbers(firstNumber : CGFloat, secondNumber : CGFloat) -> CGFloat {
        return CGFloat(arc4random())/CGFloat(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
    }
    
}

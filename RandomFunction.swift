//
//  RandomFunction.swift
//  PacyBird
//
//  Created by Levesque Frederic M. on 3/22/18.
//  Copyright © 2018 Levesque Frederic M. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat{
    
    public static func random() -> CGFloat{
        
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        
    }
    
    public static func random( min min : CGFloat, max: CGFloat) -> CGFloat{
        
        return CGFloat.random() * (max - min) + min
    }
    
}

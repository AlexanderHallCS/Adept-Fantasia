//
//  PlayElements.swift
//  Adept Fantasia
//
//  Created by Alexander Hall on 10/15/18.
//  Copyright © 2018 Hall Inc. All rights reserved.
//

import UIKit
import GameplayKit
import SpriteKit

extension PlayScene {
    
    func createPlayBackground() -> SKNode {
        let backgroundNode = SKNode()
        //let spacing = 36 * scaleFactor
        var spacing:CGFloat = 0
        
        //let viewRect = CGRect(origin: super.view?.bounds.midX, size: super.view?.bounds.midY)
        //self.size.width / 4 * -1
        //(super.view?.bounds.midX)! - (super.view?.bounds.midX)! <-- 0
        
       for index in 0...19 {
            let node = SKSpriteNode(imageNamed: String(format: "AdeptFantasiaPlayBackground_0%d", index+1))
            //node.setScale(scaleFactor)
            node.anchorPoint = CGPoint(x: 0.5, y:0)
        
        node.position = CGPoint(x: 0, y: spacing * node.size.height)
            //node.position = CGPoint(x: 0, y: spacing * CGFloat(index))
        spacing+=1
            backgroundNode.addChild(node)
        }
        
        return backgroundNode
    }
    
}


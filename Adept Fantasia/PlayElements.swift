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
        let spacing = 36 * scaleFactor
        //print("createdPlayBackground!")
       /*for index in 0...0 {
            let node = SKSpriteNode(imageNamed: String(format: "AdeptFantasiaPlayBackground_%d", index+1))
            node.setScale(scaleFactor)
            node.anchorPoint = CGPoint(x: 0.5, y:0)
            node.position = CGPoint(x: self.size.width / 2, y: spacing * CGFloat(index))
            backgroundNode.addChild(node)
        } */
        let node = SKSpriteNode(imageNamed: "AdeptFantasiaPlayBackground_01")
        node.setScale(scaleFactor)
        node.anchorPoint = CGPoint(x: 0.5, y:0)
        node.position = CGPoint(x: self.size.width / 2, y: spacing)
        //node.position = CGPoint(x: self.size.width / 2, y: spacing * CGFloat(index))
        backgroundNode.addChild(node)
        return backgroundNode
    }
    
}


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

var arrayBGs :[SKSpriteNode] = [SKSpriteNode]()

extension PlayScene {
    
    func createPlayBackground() {
        
        for i in 0...3 {
            let backgroundNode = SKSpriteNode(imageNamed: "AdeptFantasiaPlayBackground")
            backgroundNode.name = "Space"
            backgroundNode.size = CGSize(width: (self.scene?.size.width)!, height: (self.scene?.size.height)!)
            backgroundNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            backgroundNode.position = CGPoint(x: 0, y: CGFloat(i) * backgroundNode.size.height - 1)
            self.addChild(backgroundNode)
        }
    }
    
    func goThroughSpace() {
        self.enumerateChildNodes(withName: "Space", using: ({
        (node, error) in
            node.position.y -= 6
            
            if (node.position.y < -(self.scene?.size.height)!) {
                node.position.y += (self.scene?.size.height)! * 3
            }
            
        }))
    }
    
}


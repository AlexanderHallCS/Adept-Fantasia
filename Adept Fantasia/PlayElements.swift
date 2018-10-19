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
        /*var spacing:CGFloat = 0
        
       for index in 0...19 {
            let node = SKSpriteNode(imageNamed: String(format: "AdeptFantasiaPlayBackground_0%d", index+1))
        node.size.width = self.size.width
        //may need to edit this line to / 20
        node.size.height = self.size.height / 19
        // or this line to make it self.size.height - something else
        node.position = CGPoint(x: 0, y: (self.size.height - self.size.height/2) - (spacing*node.size.height))
        arrayBGs.append(node)
        spacing+=1
            backgroundNode.addChild(node)
        }
        return backgroundNode */
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


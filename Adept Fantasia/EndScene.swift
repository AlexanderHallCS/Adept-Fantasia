//
//  EndScene.swift
//  Adept Fantasia
//
//  Created by Alexander Hall on 10/11/18.
//  Copyright © 2018 Hall Inc. All rights reserved.
//

import SpriteKit
import GameplayKit

class EndScene: SKScene {
    
    override func didMove(to view: SKView) {
        
        if(didWin == true) {
            let winLabel = SKLabelNode()
            winLabel.text = "You Won!"
            winLabel.fontName = "Baskerville"
            winLabel.fontSize = 180
            winLabel.fontColor = .magenta
            winLabel.position = CGPoint(x: 0, y: self.size.height/4)
            winLabel.zPosition = 1
            addChild(winLabel)
        } else {
            let loseLabel = SKLabelNode()
            loseLabel.text = "You Lost!"
            loseLabel.fontName = "Baskerville"
            loseLabel.fontSize = 180
            loseLabel.fontColor = .magenta
            loseLabel.position = CGPoint(x: 0, y: self.size.height/4)
            loseLabel.zPosition = 1
            addChild(loseLabel)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}


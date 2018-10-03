//
//  StartScene.swift
//  Adept Fantasia
//
//  Created by Alexander Hall on 10/1/18.
//  Copyright © 2018 Hall Inc. All rights reserved.
//

import SpriteKit
import GameplayKit

class StartScene: SKScene {
    
    override func didMove(to view: SKView) {
        
    }
    
    
     /*func touchDown(atPoint pos : CGPoint) {
     
     }
     
     func touchMoved(toPoint pos : CGPoint) {
     
     }
     
     func touchUp(atPoint pos : CGPoint) {
     
     } */
    
    //right click button in storyboard and delete any outlet connections to unwanted classes when debugging
    /*@IBAction func playButtonTap(_ sender: Any) {
        let gameSceneMain = GameScene(fileNamed: "GameScene")
        self.scene?.view?.presentScene(gameSceneMain!, transition: SKTransition.crossFade(withDuration: 1.0))
    } */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*for t in touches { self.touchDown(atPoint: t.location(in: self)) }
        let gameSceneMain = GameScene(fileNamed: "GameScene")
        self.scene?.view?.presentScene(gameSceneMain!, transition: SKTransition.crossFade(withDuration: 1.0))
        print("ran!") */
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


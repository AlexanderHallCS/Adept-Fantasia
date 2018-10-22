//
//  PlayScene.swift
//  Adept Fantasia
//
//  Created by Alexander Hall on 10/11/18.
//  Copyright © 2018 Hall Inc. All rights reserved.
//

import SpriteKit
import GameplayKit

class PlayScene: SKScene {
    
    var characterTexture = SKTexture(imageNamed: "CharacterImage.png")
    var bossTexture = SKTexture(imageNamed: "BossImage.png")
    
    var character = SKSpriteNode();
    var boss = SKSpriteNode();
    var background:SKNode!
    
    var charLocX: CGFloat = 0;
    var charLocY: CGFloat = 0;
    var bossLocX: CGFloat = 0;
    var bossLocY: CGFloat = 0;
    
   
    
    override func didMove(to view: SKView) {
        
        character = SKSpriteNode(texture: characterTexture)
        character.position = CGPoint(x: 0, y: self.size.height/2 * -1 + self.size.height/14)
        character.zPosition = 1
        addChild(character)
        
        boss = SKSpriteNode(texture: bossTexture)
        boss.size = CGSize(width: 300, height: 300)
        boss.position = CGPoint(x: 0, y: self.size.height/4)
        bossLocY = self.size.height/4
        //brings out the boss to the front
        boss.zPosition = 1
        addChild(boss)
        
        //let rect = CGRect(x: 0, y: self.size.height/4 - 200, width: 100, height: 100)
        //let circle = UIBezierPath(roundedRect: rect, cornerRadius: 100)
        //let followCircle = SKAction.follow(circle.cgPath, asOffset: true, orientToPath: false, duration: 5.0)
        
        let line = CGRect(x: 0, y: self.size.height/4 - 200, width: 200, height: 1)
        let linePath = UIBezierPath(roundedRect: line, cornerRadius: 100)
        let followLinePath = SKAction.follow(linePath.cgPath, asOffset: true, orientToPath: false, speed: 50)
        
        UIView.animate(withDuration: 2.0, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat], animations: {
            
            self.boss.run(followLinePath)
            
        }, completion: nil)
        
        createPlayBackground()
        
        //while(true) {
         //   if(boss.position.x == 0 && boss.position.y == self.size.height/4) {
        
       //     }
     //   }
        
    }
    /*func touchDown(atPoint pos : CGPoint) {
     
     }
     
     func touchMoved(toPoint pos : CGPoint) {
     
     }
     
     func touchUp(atPoint pos : CGPoint) {
     
     } */
    
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
        goThroughSpace()
        
    }
}


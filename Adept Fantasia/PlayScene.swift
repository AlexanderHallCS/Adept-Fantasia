//
//  PlayScene.swift
//  Adept Fantasia
//
//  Created by Alexander Hall on 10/11/18.
//  Copyright © 2018 Hall Inc. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
import UIKit

class PlayScene: SKScene, SKPhysicsContactDelegate {
    
    var charBulletCategory:UInt32 = 0x1 << 0 //1
    var bossCategory:UInt32 = 0x1 << 1 //2
    
    var characterTexture = SKTexture(imageNamed: "CharacterImage.png")
    var bossTexture = SKTexture(imageNamed: "BossImage.png")
    
    var character = SKSpriteNode()
    var boss = SKSpriteNode()
    var bossHealthBar = SKSpriteNode()
    var background:SKNode!
    
    var charLocX: CGFloat = 0.0
    var negBossAccel = false
    
    var charBullets :[SKSpriteNode] = [SKSpriteNode]()
    var charBulletTexture = SKTexture(imageNamed: "Bullet1.png")
    
    var firstHourGlassHalf = true
    var bossHealthPercentage: Float = 0.0
    var bossHealth = 50000
    var unfilledBossHealthBarTexture = SKTexture(imageNamed: "UnfilledBossHealthBar.png")
    var filledBossHealthBarTexture = SKTexture(imageNamed: "FilledBossHealthBar.png")
    let bossHealthLabel = SKLabelNode()
    
    let motionManager: CMMotionManager = CMMotionManager()
    
    override func didMove(to view: SKView) {
        
        bossHealthLabel.text = "Boss Health:  \(bossHealth)"
        bossHealthLabel.fontName = "Baskerville"
        bossHealthLabel.fontSize = 60
        bossHealthLabel.fontColor = .green
        bossHealthLabel.position = CGPoint(x: -107, y: self.size.height/4 + 270)
        bossHealthLabel.zPosition = 1
        addChild(bossHealthLabel)
        
        bossHealthBar = SKSpriteNode(texture: filledBossHealthBarTexture)
        bossHealthBar.position = CGPoint(x: 0, y: self.size.height/4 + 240)
        bossHealthBar.size = CGSize(width: self.size.width - 60, height: 40)
        bossHealthBar.zPosition = 1
        addChild(bossHealthBar)
        
        character.name = "player"
        character = SKSpriteNode(texture: characterTexture)
        character.position = CGPoint(x: 0, y: self.size.height/2 * -1 + self.size.height/14)
        character.zPosition = 1
        addChild(character)
        
        boss.name = "eyb0ss"
        boss = SKSpriteNode(texture: bossTexture)
        boss.size = CGSize(width: 300, height: 300)
        boss.position = CGPoint(x: 0, y: self.size.height/4)
        boss.physicsBody? = SKPhysicsBody(circleOfRadius: boss.size.width/16)
        boss.physicsBody?.categoryBitMask = bossCategory
        boss.physicsBody?.collisionBitMask = 1
        boss.physicsBody?.contactTestBitMask = 1
        boss.zPosition = 1
        addChild(boss)
        
        //can't instatiate this timer and the other one at the same time because they conflict
        /*let bossLinetimer = Timer.scheduledTimer(timeInterval: 0.007, target: self, selector: #selector(moveBossInALine), userInfo: nil, repeats: true) */
        //bossLinetimer.fire()
        
        let bossHourglassTimer = Timer.scheduledTimer(timeInterval: 0.002, target: self, selector: #selector(moveBossInHourglassFormation), userInfo: nil, repeats: true)
        bossHourglassTimer.fire()
        
        createPlayBackground()
        
        if motionManager.isAccelerometerAvailable == true {
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!)  { (data, error) in
                let currentX = self.character.position.x
                
                if data!.acceleration.x < 0.0 {
                    if(!(currentX < -280)) {
                    self.charLocX = currentX + CGFloat((data?.acceleration.x)! * 100)
                    }
                } else if data!.acceleration.x > 0.0 {
                    if(!(currentX > 310)) {
                    self.charLocX = currentX + CGFloat((data?.acceleration.x)! * 100)
                    }
                }
                //accelerating too fast causes the character to fuse with the screen boundaries --> set a min/max x better
                self.character.physicsBody?.velocity = CGVector(dx: (data?.acceleration.x)! * 9.0, dy: 0)
            }
        }
        
        character.physicsBody?.usesPreciseCollisionDetection = true
        character.physicsBody = SKPhysicsBody(circleOfRadius: max(character.size.width / 2, character.size.height / 2))
        character.physicsBody?.affectedByGravity = false
        //0b01
        //character.physicsBody?.collisionBitMask = UInt32(1)
        //fix this boundary --> character.physicsBody? = SKPhysicsBody(edgeLoopFrom: frame)
        character.physicsBody? = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: self.size.width - 50, height: self.size.height))
        
        physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if(charBullets.count > 0) {
            //print("touched")
            //print(contact.bodyA.node?.name)
            //char bullet goes out of bounds
            for i in 0..<charBullets.count {
                if(charBullets[i].position.y > self.size.height/4 + 320) {
                    charBullets[i].removeFromParent()
                }
            }
            
            for i in 0..<charBullets.count {
                if(charBullets[i].position.y > boss.position.y - 40 && (charBullets[i].position.x < boss.position.x + 60 && charBullets[i].position.x > boss.position.x - 60)) {
                    charBullets[i].removeFromParent()
                    bossHealth -= 1
                    bossHealthLabel.text = "Boss Health \(bossHealth)"
                }
            }
        }
    }
    
    @objc func moveBossInALine() {
        if(boss.position.x < 310 && negBossAccel == false) {
            boss.position.x = boss.position.x + 1
            if(boss.position.x == 309) {
                negBossAccel = true
            }
        }
        if(boss.position.x < 310 && negBossAccel == true){
            boss.position.x = boss.position.x-1
            if(boss.position.x < -280) {
                negBossAccel = false
            }
        }
    }
    
    @objc func moveBossInHourglassFormation() {
        print("Boss's x: \(boss.position.x) \n Boss's y: \(boss.position.y)")
        if(boss.position.x > -150 && firstHourGlassHalf == true) {
            print("Boss's x1: \(boss.position.x) \n Boss's y1: \(boss.position.y)")
           // print("Inside Ran!")
            boss.position.x = boss.position.x - 1
            boss.position.y = boss.position.y - 1
        }
        if(boss.position.x == -150 && boss.position.y < self.size.height/4 && firstHourGlassHalf == true) {
            boss.position.y = boss.position.y + 1
        }
        
        if(boss.position.x == -150 && boss.position.y == self.size.height/4) {
            firstHourGlassHalf = false
        }
        
        if(boss.position.y <= self.size.height/4 && boss.position.x < 0 && firstHourGlassHalf == false) {
            boss.position.x = boss.position.x + 1
            boss.position.y = boss.position.y - 1
        }
        
        if(boss.position.x == 0 && boss.position.y < self.size.height/4 && firstHourGlassHalf == false) {
            boss.position.y = boss.position.y + 1
        }
        
        if(boss.position.x == 0 && boss.position.y == self.size.height/4) {
            firstHourGlassHalf = true
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let charBullet = SKSpriteNode(texture: charBulletTexture)
        charBullet.physicsBody = SKPhysicsBody(circleOfRadius: charBullet.size.width/128)
        charBullet.position = CGPoint(x: character.position.x, y: character.position.y + 100)
        charBullet.zPosition = 1
        charBullet.physicsBody?.affectedByGravity = false
        charBullet.physicsBody?.velocity = CGVector.init(dx: 0, dy: 500)
        charBullet.physicsBody?.categoryBitMask = charBulletCategory
        charBullet.physicsBody?.collisionBitMask = 1
        charBullet.physicsBody?.contactTestBitMask = bossCategory
        addChild(charBullet)
        charBullets.append(charBullet)
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
        let moveCharX = SKAction.moveTo(x: charLocX, duration: 0.08)
        self.character.run(moveCharX)
        goThroughSpace()
    }
}


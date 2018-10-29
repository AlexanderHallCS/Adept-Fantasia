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
        boss.physicsBody?.categoryBitMask = bossCategory
        boss.physicsBody?.collisionBitMask = 0
        boss.physicsBody?.contactTestBitMask = 0
        //brings out the boss to the front
        boss.zPosition = 1
        addChild(boss)
        
        //let rect = CGRect(x: 0, y: self.size.height/4 - 200, width: 100, height: 100)
        //let circle = UIBezierPath(roundedRect: rect, cornerRadius: 100)
        //let followCircle = SKAction.follow(circle.cgPath, asOffset: true, orientToPath: false, duration: 5.0)
        
        let timer = Timer.scheduledTimer(timeInterval: 0.007, target: self, selector: #selector(moveBossInALine), userInfo: nil, repeats: true)
        timer.fire()
        
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
            print("touched")
            //print(contact.bodyA.node?.name)
            //char bullet goes out of bounds
            /*for i in 0..<charBullets.count {
                if(charBullets[i].position.y > self.size.height/4 + 320) {
                    charBullets[i].removeFromParent()
                }
            }
            
            //char bullet touches boss
            for i in 0..<charBullets.count {
                if(charBullets[i].position.y > boss.position.y - 40 && (charBullets[i].position.x < boss.position.x + 60 && charBullets[i].position.x > boss.position.x - 60)) {
                    charBullets[i].removeFromParent()
                    bossHealth -= 1
                    bossHealthLabel.text = "Boss Health \(bossHealth)"
                }
            } */
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
        /*let line = CGRect(x: 0, y: self.size.height/4 - 200, width: 200, height: 1)
        let linePath = UIBezierPath(roundedRect: line, cornerRadius: 100)
        let followLinePath = SKAction.follow(linePath.cgPath, asOffset: true, orientToPath: false, speed: 50)
        self.boss.run(followLinePath) */
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let charBullet = SKSpriteNode(texture: charBulletTexture)
        charBullet.physicsBody = SKPhysicsBody(circleOfRadius: charBullet.size.width/128)
        charBullet.position = CGPoint(x: character.position.x, y: character.position.y + 100)
        charBullet.zPosition = 1
        charBullet.physicsBody?.affectedByGravity = false
        charBullet.physicsBody?.velocity = CGVector.init(dx: 0, dy: 500)
        charBullet.physicsBody?.categoryBitMask = charBulletCategory
        charBullet.physicsBody?.collisionBitMask = 0
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


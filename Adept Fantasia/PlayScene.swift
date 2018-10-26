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

class PlayScene: SKScene {
    
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
    var bossHealth = 258
    var unfilledBossHealthBarTexture = SKTexture(imageNamed: "UnfilledBossHealthBar.png")
    var filledBossHealthBarTexture = SKTexture(imageNamed: "FilledBossHealthBar.png")
    
    let motionManager: CMMotionManager = CMMotionManager()
    
    override func didMove(to view: SKView) {
        
        bossHealthBar = SKSpriteNode(texture: filledBossHealthBarTexture)
        bossHealthBar.position = CGPoint(x: 0, y: self.size.height/4 + 240)
        bossHealthBar.size = CGSize(width: self.size.width - 60, height: 40)
        bossHealthBar.zPosition = 1
        addChild(bossHealthBar)
        
        character = SKSpriteNode(texture: characterTexture)
        character.position = CGPoint(x: 0, y: self.size.height/2 * -1 + self.size.height/14)
        character.zPosition = 1
        addChild(character)
        
        boss = SKSpriteNode(texture: bossTexture)
        boss.size = CGSize(width: 300, height: 300)
        boss.position = CGPoint(x: 0, y: self.size.height/4)
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
                self.character.physicsBody?.velocity = CGVector(dx: (data?.acceleration.x)! * 9.0, dy: 0)
            }
        }
        
        character.physicsBody?.usesPreciseCollisionDetection = true
        character.physicsBody = SKPhysicsBody(circleOfRadius: max(character.size.width / 2, character.size.height / 2))
        character.physicsBody?.affectedByGravity = false
        //0b01
        character.physicsBody?.collisionBitMask = UInt32(1)
        //fix this boundary --> character.physicsBody? = SKPhysicsBody(edgeLoopFrom: frame)
        character.physicsBody? = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: self.size.width - 50, height: self.size.height))
        
        //i is of type SKSpriteNode(references the values in the array)
        for i in charBullets {
            if(i.position.x == boss.position.x) {
                print("touched")
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
        /*let line = CGRect(x: 0, y: self.size.height/4 - 200, width: 200, height: 1)
        let linePath = UIBezierPath(roundedRect: line, cornerRadius: 100)
        let followLinePath = SKAction.follow(linePath.cgPath, asOffset: true, orientToPath: false, speed: 50)
        self.boss.run(followLinePath) */
    }
    
    @objc func updateBossHealthProgressBar() {
       // bossHealthBar.setProgress(bossHealthPercentage, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let charBullet = SKSpriteNode(texture: charBulletTexture)
        charBullet.physicsBody = SKPhysicsBody(circleOfRadius: charBullet.size.width/32)
        charBullet.physicsBody?.usesPreciseCollisionDetection = true
        charBullet.position = CGPoint(x: character.position.x, y: character.position.y + 100)
        charBullet.zPosition = 1
        charBullet.physicsBody?.isDynamic = true
        charBullet.physicsBody?.affectedByGravity = false
        charBullet.physicsBody?.velocity = CGVector.init(dx: 0, dy: 500)
        //0b10
        charBullet.physicsBody?.collisionBitMask = UInt32(2)
        print(character.position.y)
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
        //perform(#selector(updateBossHealthProgressBar), with: nil)
        goThroughSpace()
    }
}


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

enum ColliderType:UInt32 {
    case bulletCategory = 1
    case bossCategory = 2
}

class PlayScene: SKScene, SKPhysicsContactDelegate {
    
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size:CGSize) {
        super.init(size: size)
        
    }
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
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
        
        character = SKSpriteNode(texture: characterTexture)
        character.name = "player"
        character.position = CGPoint(x: 0, y: self.size.height/2 * -1 + self.size.height/14)
        character.zPosition = 1
        addChild(character)
        
        boss = SKSpriteNode(texture: bossTexture)
        boss.name = "boss"
        boss.physicsBody = SKPhysicsBody(texture: bossTexture, size: bossTexture.size())
        boss.physicsBody?.usesPreciseCollisionDetection = true
        boss.physicsBody!.isDynamic = true
        boss.physicsBody!.affectedByGravity = false
        boss.size = CGSize(width: 300, height: 300)
        boss.physicsBody!.categoryBitMask = ColliderType.bossCategory.rawValue
        boss.physicsBody!.collisionBitMask = 0
        boss.physicsBody!.contactTestBitMask = ColliderType.bulletCategory.rawValue
        boss.zPosition = 1
        boss.position = CGPoint(x: 0, y: self.size.height/4)
        addChild(boss)
        
        //can't instatiate this timer and the other one at the same time because they conflict
        /*let bossLinetimer = Timer.scheduledTimer(timeInterval: 0.007, target: self, selector: #selector(moveBossInALine), userInfo: nil, repeats: true) */
        //bossLinetimer.fire()
        
        let checkOOB = Timer.scheduledTimer(timeInterval: 0.007, target: self, selector: #selector(checkForOOB), userInfo: nil, repeats: true)
        checkOOB.fire()
        
        let bossHourglassPath = UIBezierPath()
        /*bossHourglassPath.move(to: CGPoint(x: -220, y: -200))
        bossHourglassPath.addLine(to: CGPoint(x: -220, y: -200))
        bossHourglassPath.addLine(to: CGPoint(x: -220, y: 100))
        bossHourglassPath.addLine(to: CGPoint(x: 300, y: -200))
        bossHourglassPath.addLine(to: CGPoint(x: 300, y: 100))
        bossHourglassPath.addLine(to: CGPoint(x:-220 , y: -200)) */
        
        bossHourglassPath.move(to: CGPoint(x: -220, y: 0))
        bossHourglassPath.addLine(to: CGPoint(x: -220, y: 0))
        bossHourglassPath.addLine(to: CGPoint(x: -220, y: 400))
        bossHourglassPath.addLine(to: CGPoint(x: 300, y: 0))
        bossHourglassPath.addLine(to: CGPoint(x: 300, y: 400))
        bossHourglassPath.addLine(to: CGPoint(x:-220 , y: 0))
        
        //setting asOffset as false makes the x and y positions literal as opposed to based on an anchor
        let move = SKAction.follow(bossHourglassPath.cgPath, asOffset: false, orientToPath: false, speed: 150)
        boss.run(SKAction.repeatForever(move))
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
        
        //character.physicsBody?.usesPreciseCollisionDetection = true
        //character.physicsBody = SKPhysicsBody(circleOfRadius: max(character.size.width / 2, character.size.height / 2))
        character.physicsBody?.affectedByGravity = false
        //0b01
        //character.physicsBody?.collisionBitMask = UInt32(1)
        //fix this boundary --> character.physicsBody? = SKPhysicsBody(edgeLoopFrom: frame)
        character.physicsBody? = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: self.size.width - 50, height: self.size.height))
        //self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    @objc func checkForOOB() {
        for i in 0..<charBullets.count {
            if(charBullets[i].position.y > self.size.height/4 + 320) {
                charBullets[i].removeFromParent()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if(charBullets.count > 0) {
            var firstBody = SKPhysicsBody()
            var secondBody = SKPhysicsBody()
            
            if(contact.bodyA.node?.name == "bullet") {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            } else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            for i in 0..<charBullets.count {
            if(firstBody.node?.name == "bullet" && secondBody.node?.name == "boss") {
                    print("hit the boss!")
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let charBullet = SKSpriteNode(texture: charBulletTexture)
        charBullet.name = "bullet"
        charBullet.physicsBody = SKPhysicsBody(texture: charBulletTexture, size: charBulletTexture.size())
        charBullet.zPosition = 1
        charBullet.physicsBody!.isDynamic = true
        charBullet.physicsBody!.usesPreciseCollisionDetection = true
        charBullet.physicsBody!.affectedByGravity = false
        charBullet.physicsBody!.velocity = CGVector.init(dx: 0, dy: 450)
        charBullet.physicsBody!.categoryBitMask = ColliderType.bulletCategory.rawValue
        charBullet.physicsBody!.collisionBitMask = 0
        charBullet.physicsBody!.contactTestBitMask = ColliderType.bossCategory.rawValue
        charBullet.position = CGPoint(x: character.position.x, y: character.position.y + 100)
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


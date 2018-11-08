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
    case bulletCategory = 0b01
    case bossCategory = 0b10
    case invulnerabilityCategory = 0b100
    case characterCategory = 0b1000
    case bossBulletCategory = 0b10000
}

class PlayScene: SKScene, SKPhysicsContactDelegate {
    
    
    var invulnerabilityTexture = SKTexture(imageNamed: "InvulnerabilityPowerup")
    var characterTexture = SKTexture(imageNamed: "CharacterImage")
    var bossTexture = SKTexture(imageNamed: "BossImage")
    
    var character = SKSpriteNode()
    var boss = SKSpriteNode()
    var bossHealthBar = SKSpriteNode()
    var invulnerabilityPowerup = SKSpriteNode()
    
    var invulnerabilityPowerupOn = false
    
    var charLocX: CGFloat = 0.0
    var negBossAccel = false
    
    var charBullets :[SKSpriteNode] = [SKSpriteNode]()
    var charBulletTexture = SKTexture(imageNamed: "Bullet1.png")
    
    var bossBullets :[SKSpriteNode] = [SKSpriteNode]()
    var bossBulletTexture = SKTexture(imageNamed: "Bullet2.png")
    
    var firstHourGlassHalf = true
    var bossHealthPercentage: Float = 0.0
    var bossHealth = 10000
    var unfilledBossHealthBarTexture = SKTexture(imageNamed: "UnfilledBossHealthBar.png")
    var filledBossHealthBarTexture = SKTexture(imageNamed: "FilledBossHealthBar.png")
    let bossHealthLabel = SKLabelNode()
    
    var invulnerabilityPowerupHealth = 20
    var characterHealth = 20
    
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
        character.name = "character"
        character.position = CGPoint(x: 0, y: self.size.height/2 * -1 + self.size.height/14)
        character.zPosition = 1
        character.physicsBody = SKPhysicsBody(texture: characterTexture, size: characterTexture.size())
        character.physicsBody!.isDynamic = true
        character.physicsBody!.usesPreciseCollisionDetection = true
        character.physicsBody!.affectedByGravity = false
        character.physicsBody!.categoryBitMask = ColliderType.characterCategory.rawValue
        character.physicsBody!.collisionBitMask = 0
        character.physicsBody!.contactTestBitMask = ColliderType.bossBulletCategory.rawValue
        addChild(character)
        
        boss = SKSpriteNode(texture: bossTexture)
        boss.name = "boss"
        boss.physicsBody = SKPhysicsBody(texture: bossTexture, size: bossTexture.size())
        boss.physicsBody!.usesPreciseCollisionDetection = true
        boss.physicsBody!.isDynamic = true
        boss.physicsBody!.affectedByGravity = false
        boss.size = CGSize(width: 300, height: 300)
        boss.physicsBody!.categoryBitMask = ColliderType.bossCategory.rawValue
        boss.physicsBody!.collisionBitMask = 0
        boss.physicsBody!.contactTestBitMask = ColliderType.bulletCategory.rawValue
        boss.zPosition = 1
        boss.position = CGPoint(x: 0, y: self.size.height/4)
        addChild(boss)
        
        invulnerabilityPowerup = SKSpriteNode(texture: invulnerabilityTexture)
        invulnerabilityPowerup.name = "invulnerability"
        invulnerabilityPowerup.physicsBody = SKPhysicsBody(texture: invulnerabilityTexture, size: invulnerabilityPowerup.size)
        invulnerabilityPowerup.physicsBody!.usesPreciseCollisionDetection = true
        invulnerabilityPowerup.physicsBody!.isDynamic = true
        invulnerabilityPowerup.physicsBody!.affectedByGravity = false
        invulnerabilityPowerup.size = CGSize(width: 250, height:250)
        invulnerabilityPowerup.position = CGPoint(x: character.position.x + 600, y: character.position.y + 350)
        invulnerabilityPowerup.zPosition = 1
        invulnerabilityPowerup.physicsBody!.categoryBitMask = ColliderType.invulnerabilityCategory.rawValue
        invulnerabilityPowerup.physicsBody!.collisionBitMask = 0
        invulnerabilityPowerup.physicsBody!.contactTestBitMask = ColliderType.bulletCategory.rawValue
        addChild(invulnerabilityPowerup)
        
        let checkBulletOOB = Timer.scheduledTimer(timeInterval: 0.007, target: self, selector: #selector(checkForBulletOOB), userInfo: nil, repeats: true)
        checkBulletOOB.fire()
        
        let invulnerabilityPath = UIBezierPath()
        invulnerabilityPath.move(to: CGPoint(x: character.position.x + 500, y: character.position.y + 350))
        invulnerabilityPath.addLine(to: CGPoint(x: -500, y: 420))
        let invulnerabilityMove = SKAction.follow(invulnerabilityPath.cgPath, asOffset: false, orientToPath: false, speed: 90)
        invulnerabilityPowerup.run(invulnerabilityMove)
        
        let checkInvulnerabilityOOB = Timer.scheduledTimer(timeInterval: 0.007, target: self, selector: #selector(checkInvulnerabilityPowerupOOB), userInfo: nil, repeats: true)
        checkInvulnerabilityOOB.fire()
        
        let checkInvulnerabilityHealth = Timer.scheduledTimer(timeInterval: 0.007, target: self, selector: #selector(checkInvulnerabilityPowerupHealth), userInfo: nil, repeats: true)
        if(!intersects(invulnerabilityPowerup)) {
        checkInvulnerabilityHealth.fire()
        }
        
        let bossLinearAttack = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(bossLinearAttackFire), userInfo: nil, repeats: true)
        bossLinearAttack.fire()
        
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
        
        let bossLinearPath = UIBezierPath()
        bossLinearPath.move(to: CGPoint(x: 0, y: self.size.height/4))
        bossLinearPath.addLine(to: CGPoint(x: 310, y: self.size.height/4))
        bossLinearPath.addLine(to: CGPoint(x: -280, y: self.size.height/4))
        bossLinearPath.addLine(to: CGPoint(x: 0, y: self.size.height/4))
        let bossLinearMove = SKAction.follow(bossLinearPath.cgPath, asOffset: false, orientToPath: false, speed: 150)
        //boss.run(SKAction.repeat(bossLinearMove, count: 3))
        
        let bossHourglassPath = UIBezierPath()
        bossHourglassPath.move(to: CGPoint(x: -220, y: self.size.height/4 - 100))
        bossHourglassPath.addLine(to: CGPoint(x: -220, y: self.size.height/4 - 100))
        bossHourglassPath.addLine(to: CGPoint(x: -220, y: 400))
        bossHourglassPath.addLine(to: CGPoint(x: 300, y: self.size.height/4 - 100))
        bossHourglassPath.addLine(to: CGPoint(x: 300, y: 400))
        bossHourglassPath.addLine(to: CGPoint(x:-220 , y: self.size.height/4 - 100))
        
        let bossHourglassMove = SKAction.follow(bossHourglassPath.cgPath, asOffset: false, orientToPath: false, speed: 150)
        //boss.run(SKAction.repeat(bossHourglassMove, count: 3))
        
       // spiralBulletAttack()
    }
    
    @objc func checkInvulnerabilityPowerupOOB() {
        if(invulnerabilityPowerup.position.x < -490) {
            invulnerabilityPowerup.removeFromParent()
        }
    }
    
    @objc func checkInvulnerabilityPowerupHealth() {
        if(invulnerabilityPowerupHealth == 0) {
            invulnerabilityPowerup.removeFromParent()
            //----------------------
            //and give the character invulnerability from boss's bullets
            //----------------------
            invulnerabilityPowerupOn = true
        }
    }
    
    @objc func checkForBulletOOB() {
        for i in 0..<charBullets.count {
            if(charBullets[i].position.y > self.size.height/4 + 320) {
                charBullets[i].removeFromParent()
            }
        }
        
        for i in 0..<bossBullets.count {
            if(bossBullets[i].position.y < -700) {
                bossBullets[i].removeFromParent()
            }
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //print("contact!")
        if(charBullets.count > 0) {
            //collision between boss and charbullets
            var firstBody = SKPhysicsBody()
            var secondBody = SKPhysicsBody()
            
            //collision between invulnerability powerup and charbullets
            var thirdBody = SKPhysicsBody()
            var fourthBody = SKPhysicsBody()
            
            //collision between character and bossbullets
            var fifthBody = SKPhysicsBody()
            var sixthBody = SKPhysicsBody()
            
            if(contact.bodyA.node?.name == "bullet") {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            } else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            for i in 0..<charBullets.count {
                if(firstBody.node == charBullets[i] && secondBody.node?.name == "boss") {
                    charBullets[i].removeFromParent()
                    bossHealth -= 1
                    bossHealthLabel.text = "Boss Health \(bossHealth)"
                }
            }
            
            if(contact.bodyB.node?.name == "invulnerability") {
                thirdBody = contact.bodyA
                fourthBody = contact.bodyB
            } else {
                thirdBody = contact.bodyB
                fourthBody = contact.bodyA
            }
            
            for i in 0..<charBullets.count {
                if(thirdBody.node == charBullets[i] && fourthBody.node?.name == "invulnerability") {
                    charBullets[i].removeFromParent()
                    invulnerabilityPowerupHealth -= 1
                    print("Invulnerability Powerup Health: \(invulnerabilityPowerupHealth)")
                }
            }
            
            if(contact.bodyB.node?.name == "character") {
                print("test1")
                fifthBody = contact.bodyA
                sixthBody = contact.bodyB
            } else {
                print("test2")
                fifthBody = contact.bodyB
                sixthBody = contact.bodyA
            }
            
            for i in 0..<bossBullets.count {
                if(fifthBody.node == bossBullets[i] && sixthBody.node?.name == "character") {
                    bossBullets[i].removeFromParent()
                    characterHealth = characterHealth - 1
                    print("collision hit character!")
                }
            }
            
        }
    }
    
    /*func sin(degrees: Double) -> Double {
        return __sinpi(degrees/180.0)
    } */
    
    func spiralBulletAttack() {
        //decrease bosshealthbar with unfilledbosshealthbar
        //make the game end when the boss's health is 0
        //change the music to start when the app is opened and end when the game is over
        
        /*var x:CGFloat = 1
        var y:CGFloat = 1
        var a = 2
        
        var iterator:CGFloat = 0.0
        
        var arctan = atan(y/x)
        
        for i in 0...360 {
            x = pow((pow(2, 2)*pow((arctan - iterator),2) - pow(y,2)),0.5)
            y = pow((pow(2, 2)*pow((arctan - iterator),2) - pow(x,2)),0.5)
            iterator = iterator + 1
            print("(\(x),\(y))")
        } */
        
    }
    
    @objc func bossLinearAttackFire() {
        let bossBullet = SKSpriteNode(texture: bossBulletTexture)
        bossBullet.name = "bossbullet"
        bossBullet.physicsBody = SKPhysicsBody(texture: bossBulletTexture, size: bossBulletTexture.size())
        bossBullet.zPosition = 1
        bossBullet.physicsBody!.isDynamic = true
        bossBullet.physicsBody!.usesPreciseCollisionDetection = true
        bossBullet.physicsBody!.affectedByGravity = false
        bossBullet.physicsBody!.velocity = CGVector.init(dx: 0, dy: -400)
        bossBullet.physicsBody!.categoryBitMask = ColliderType.bossBulletCategory.rawValue
        bossBullet.physicsBody!.collisionBitMask = 0
        bossBullet.physicsBody!.contactTestBitMask = ColliderType.characterCategory.rawValue
        bossBullet.position = CGPoint(x: boss.position.x, y: boss.position.y - 100)
        addChild(bossBullet)
        bossBullets.append(bossBullet)
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
        charBullet.physicsBody!.contactTestBitMask = ColliderType.bossCategory.rawValue | ColliderType.invulnerabilityCategory.rawValue
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


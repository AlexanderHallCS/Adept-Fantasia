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
import CoreData

enum ColliderType:UInt32 {
    case bulletCategory = 0b01
    case bossCategory = 0b10
    case invulnerabilityCategory = 0b100
    case characterCategory = 0b1000
    case bossBulletCategory = 0b10000
    case clearBulletCategory = 0b100000
}

class PlayScene: SKScene, SKPhysicsContactDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var clearBulletTexture = SKTexture(imageNamed: "ClearBulletsPowerup")
    var invulnerabilityTexture = SKTexture(imageNamed: "InvulnerabilityPowerup")
    var characterTexture = SKTexture(imageNamed: "CharacterImage")
    var bossTexture = SKTexture(imageNamed: "BossImage")
    
    var character = SKSpriteNode()
    var boss = SKSpriteNode()
    var bossHealthBar = SKSpriteNode()
    var invulnerabilityPowerup = SKSpriteNode()
    var clearBulletsPowerup = SKSpriteNode()
    
    var invulnerabilityPowerupOn = false
    
    var charLocX: CGFloat = 0.0
    var negBossAccel = false
    
    var charBullets :[SKSpriteNode] = [SKSpriteNode]()
    var charBulletTexture = SKTexture(imageNamed: "Bullet1.png")
    
    var bossBullets :[SKSpriteNode] = [SKSpriteNode]()
    var bossBulletTexture = SKTexture(imageNamed: "Bullet2.png")
    
    var firstHourGlassHalf = true
    var bossHealthPercentage: Float = 0.0
    var bossHealth = 200
    var unfilledBossHealthBarTexture = SKTexture(imageNamed: "UnfilledBossHealthBar.png")
    var filledBossHealthBarTexture = SKTexture(imageNamed: "FilledBossHealthBar.png")
    let bossHealthLabel = SKLabelNode()
    
    var invulnerabilityPowerupHealth = 20
    var characterHealth = 20
    var clearBulletsHealth = 20
    
    var bulletsDodgedThisGame = 0
    
    let motionManager: CMMotionManager = CMMotionManager()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size:CGSize) {
        super.init(size: size)
    }
    
    override func didMove(to view: SKView) {
        
        bulletsDodgedThisGame = 0
        
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
        
        clearBulletsPowerup = SKSpriteNode(texture: clearBulletTexture)
        clearBulletsPowerup.name = "clearbullets"
        clearBulletsPowerup.physicsBody = SKPhysicsBody(texture: clearBulletTexture, size: clearBulletsPowerup.size)
        clearBulletsPowerup.physicsBody!.usesPreciseCollisionDetection = true
        clearBulletsPowerup.physicsBody!.isDynamic = true
        clearBulletsPowerup.physicsBody!.affectedByGravity = false
        clearBulletsPowerup.size = CGSize(width: 250, height:250)
        clearBulletsPowerup.position = CGPoint(x: character.position.x - 600, y: character.position.y + 350)
        clearBulletsPowerup.zPosition = 1
        clearBulletsPowerup.physicsBody!.categoryBitMask = ColliderType.clearBulletCategory.rawValue
        clearBulletsPowerup.physicsBody!.collisionBitMask = 0
        clearBulletsPowerup.physicsBody!.contactTestBitMask = ColliderType.bulletCategory.rawValue
        addChild(clearBulletsPowerup)
        
        let checkBulletOOB = Timer.scheduledTimer(timeInterval: 0.007, target: self, selector: #selector(checkForBulletOOB), userInfo: nil, repeats: true)
        checkBulletOOB.fire()
        
        let invulnerabilityPath = UIBezierPath()
        invulnerabilityPath.move(to: CGPoint(x: character.position.x + 500, y: character.position.y + 350))
        invulnerabilityPath.addLine(to: CGPoint(x: -500, y: 420))
        let invulnerabilityMove = SKAction.follow(invulnerabilityPath.cgPath, asOffset: false, orientToPath: false, speed: 90)
        invulnerabilityPowerup.run(invulnerabilityMove)
        
        
        //don't use timers because they don't stop and can't restart
        let checkInvulnerabilityOOB = Timer.scheduledTimer(timeInterval: 0.007, target: self, selector: #selector(checkInvulnerabilityPowerupOOB), userInfo: nil, repeats: true)
        checkInvulnerabilityOOB.fire()
        
        let checkInvulnerabilityHealth = Timer.scheduledTimer(timeInterval: 0.007, target: self, selector: #selector(checkInvulnerabilityPowerupHealth), userInfo: nil, repeats: true)
        if(!intersects(invulnerabilityPowerup)) {
        checkInvulnerabilityHealth.fire()
        }
        
        let clearBulletsPath = UIBezierPath()
        clearBulletsPath.move(to: CGPoint(x: character.position.x - 600, y: character.position.y + 350))
        clearBulletsPath.addLine(to: CGPoint(x: 600, y: 420))
        let clearBulletsMove = SKAction.follow(clearBulletsPath.cgPath, asOffset: false, orientToPath: false, speed: 90)
        clearBulletsPowerup.run(clearBulletsMove)
        
        let checkClearBulletsOOB = Timer.scheduledTimer(timeInterval: 0.007, target: self, selector: #selector(checkClearBulletsPowerupOOB), userInfo: nil, repeats: true)
        checkClearBulletsOOB.fire()
        
        let checkClearBulletsHealth = Timer.scheduledTimer(timeInterval: 0.007, target: self, selector: #selector(checkClearBulletsPowerupHealth), userInfo: nil, repeats: true)
        if(!intersects(clearBulletsPowerup)) {
            checkClearBulletsHealth.fire()
        } /*else {
            checkClearBulletsHealth.invalidate()
        } */
        
        //fire at the completion of the hourglass path
        let bossLinearAttack = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(bossLinearAttackFire), userInfo: nil, repeats: true)
        
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
        
        let bossHourglassPath = UIBezierPath()
        bossHourglassPath.move(to: CGPoint(x: -220, y: self.size.height/4 - 100))
        bossHourglassPath.addLine(to: CGPoint(x: -220, y: self.size.height/4 - 100))
        bossHourglassPath.addLine(to: CGPoint(x: -220, y: 400))
        bossHourglassPath.addLine(to: CGPoint(x: 300, y: self.size.height/4 - 100))
        bossHourglassPath.addLine(to: CGPoint(x: 300, y: 400))
        bossHourglassPath.addLine(to: CGPoint(x:-220 , y: self.size.height/4 - 100))
        
        let bossHourglassMove = SKAction.follow(bossHourglassPath.cgPath, asOffset: false, orientToPath: false, speed: 150)
        
        let bossLinearPath = UIBezierPath()
        bossLinearPath.move(to: CGPoint(x: 0, y: self.size.height/4))
        bossLinearPath.addLine(to: CGPoint(x: 310, y: self.size.height/4))
        bossLinearPath.addLine(to: CGPoint(x: -280, y: self.size.height/4))
        bossLinearPath.addLine(to: CGPoint(x: 0, y: self.size.height/4))
        let bossLinearMove = SKAction.follow(bossLinearPath.cgPath, asOffset: false, orientToPath: false, speed: 150)
        boss.run(SKAction.repeat(bossLinearMove, count: 2),
                 completion: {
                    self.boss.run(SKAction.repeat(bossHourglassMove, count: 3),
                        completion: {
                          //  bossLinearAttack.fire()
                            print("completed!")
                    })
                })
    }
    
    @objc func checkInvulnerabilityPowerupOOB() {
        if(invulnerabilityPowerup.position.x < -490) {
            invulnerabilityPowerup.removeFromParent()
        }
    }
    
    @objc func checkInvulnerabilityPowerupHealth() {
        if(invulnerabilityPowerupHealth == 0) {
            invulnerabilityPowerup.removeFromParent()
            invulnerabilityPowerupOn = true
        }
    }
    
    @objc func checkClearBulletsPowerupOOB() {
        if(invulnerabilityPowerup.position.x < -490) {
            invulnerabilityPowerup.removeFromParent()
            bulletsDodgedThisGame = bulletsDodgedThisGame + 1
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Character", in: context)
            let newUser = NSManagedObject(entity: entity!, insertInto: context)
            newUser.setValue(bulletsDodgedThisGame, forKey: "totalBulletsDodged")
            
        }
    }
    
    @objc func checkClearBulletsPowerupHealth() {
        if(clearBulletsHealth == 0) {
            clearBulletsPowerup.removeFromParent()
            for i in bossBullets {
                i.removeFromParent()
            }
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
            
            //collision between clearbulletspowerup and charbullets
            var seventhBody = SKPhysicsBody()
            var eightBody = SKPhysicsBody()
            
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
                fifthBody = contact.bodyA
                sixthBody = contact.bodyB
            } else {
                fifthBody = contact.bodyB
                sixthBody = contact.bodyA
            }
            
            if(invulnerabilityPowerupOn == false) {
            for i in 0..<bossBullets.count {
                if(fifthBody.node == bossBullets[i] && sixthBody.node?.name == "character") {
                    bossBullets[i].removeFromParent()
                    characterHealth = characterHealth - 1
                   // print("collision hit character!")
                    }
                }
            }
            
            if(contact.bodyA.categoryBitMask == ColliderType.clearBulletCategory.rawValue) {
                print("test1")
                seventhBody = contact.bodyA
                eightBody = contact.bodyB
            } else if (contact.bodyB.categoryBitMask == ColliderType.clearBulletCategory.rawValue){
                print("test2")
                seventhBody = contact.bodyB
                eightBody = contact.bodyA
            }
            
            for i in 0..<charBullets.count {
                if(eightBody.node == charBullets[i] && seventhBody.node?.name == "clearbullets") {
                    charBullets[i].removeFromParent()
                    clearBulletsHealth = clearBulletsHealth - 1
                }
            }
            
        }
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


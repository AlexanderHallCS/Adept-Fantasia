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

var viewController: UIViewController?

class PlayScene: SKScene, SKPhysicsContactDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var clearBulletTexture = SKTexture(imageNamed: "ClearBulletsPowerup")
    var invulnerabilityTexture = SKTexture(imageNamed: "InvulnerabilityPowerup")
    var characterTexture = SKTexture(imageNamed: "CharacterImage")
    var bossTexture = SKTexture(imageNamed: "BossImage")
    
    var character = SKSpriteNode()
    var boss = SKSpriteNode()
    var bossHealthBar = SKSpriteNode()
    var unfilledBossHealthBar = SKSpriteNode()
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
    var bulletsFiredThisGame = 0
    
    var isInvulnerabilityOnScreen = true
    var isClearBulletsOnScreen = true
    
    var charBulletsThatHitTheBoss = 0
    
    let motionManager: CMMotionManager = CMMotionManager()
    
    var gameOver = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size:CGSize) {
        super.init(size: size)
    }
    
    override func didMove(to view: SKView) {
        
        bulletsDodgedThisGame = 0
        bulletsFiredThisGame = 0
        charBulletsThatHitTheBoss = 0
        
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
        isInvulnerabilityOnScreen = true
        addChild(invulnerabilityPowerup)
        
        let invulnerabilityPath = UIBezierPath()
        invulnerabilityPath.move(to: CGPoint(x: character.position.x + 500, y: character.position.y + 350))
        invulnerabilityPath.addLine(to: CGPoint(x: -500, y: 420))
        let invulnerabilityMove = SKAction.follow(invulnerabilityPath.cgPath, asOffset: false, orientToPath: false, speed: 90)
        invulnerabilityPowerup.run(invulnerabilityMove)
        
        /*let linearAndHourglassSequence = SKAction.sequence([SKAction.repeat(bossLinearMove, count: 2), SKAction.repeat(bossHourglassMove, count: 3)])
        boss.run(SKAction.repeatForever(linearAndHourglassSequence)) */
        
        /*boss.run(linearAndHourglassSequence,
                 completion: {
            let bossLinearAttack = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.bossLinearAttackFire), userInfo: nil, repeats: true)
        }) */
        
        
        let bossLinearAttack = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.bossLinearAttackFire), userInfo: nil, repeats: true)
        
        /*let bossCrossAttack = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.crossAttack), userInfo: nil, repeats: true) */
        
        //BOSS SNOWFLAKE ATTACK COMMENTED
        /*let bossSnowflakeAttack = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(bossSnowflakeAttackFire), userInfo: nil, repeats: true) */
        
        //uncomment when done testing boss bullet collision
        /*boss.run(SKAction.repeat(bossLinearMove, count: 2),
                 completion: {
                    self.boss.run(SKAction.repeat(bossHourglassMove, count: 3),
                        completion: {
                            //fire at the completion of the hourglass path
                            let bossLinearAttack = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.bossLinearAttackFire), userInfo: nil, repeats: true)
                          //  bossLinearAttack.fire()
                            print("completed!")
                    })
                }) */
        
        //FIX THE CLEAR BULLETS AND INVULNERABILITY POWERUPS
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if(charBullets.count > 0) {
            //collision between boss and charbullets
            var firstBody = SKPhysicsBody()
            var secondBody = SKPhysicsBody()
            
            //collision between invulnerability powerup and charbullets
            var thirdBody = SKPhysicsBody()
            var fourthBody = SKPhysicsBody()
            
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
            
            var bossAndCharBulletsIterator = 0
            while(bossAndCharBulletsIterator < charBullets.count) {
                if(firstBody.node == charBullets[bossAndCharBulletsIterator] && secondBody.node?.name == "boss") {
                    charBulletsThatHitTheBoss = charBulletsThatHitTheBoss + 1
                    charBullets[bossAndCharBulletsIterator].removeFromParent()
                    charBullets.remove(at: bossAndCharBulletsIterator)
                    bossAndCharBulletsIterator = bossAndCharBulletsIterator - 1
                    if(bossHealth > 0) {
                    bossHealth -= 1
                    bossHealthLabel.text = "Boss Health \(bossHealth)"
                    }
                    unfilledBossHealthBar = SKSpriteNode(texture: unfilledBossHealthBarTexture)
                    unfilledBossHealthBar.position = CGPoint(x: CGFloat(347 - (3.45*Double(charBulletsThatHitTheBoss))), y: self.size.height/4 + 240)
                    unfilledBossHealthBar.size = CGSize(width: 3.45, height: 40)
                    unfilledBossHealthBar.zPosition = 2
                    addChild(unfilledBossHealthBar)
                }
                bossAndCharBulletsIterator = bossAndCharBulletsIterator + 1
                }
            
            if(contact.bodyB.node?.name == "invulnerability") {
                thirdBody = contact.bodyA
                fourthBody = contact.bodyB
            } else {
                thirdBody = contact.bodyB
                fourthBody = contact.bodyA
            }
            
            var invulnerabilityAndCharBulletIterator = 0
            while(invulnerabilityAndCharBulletIterator < charBullets.count) {
                if(thirdBody.node == charBullets[invulnerabilityAndCharBulletIterator] && fourthBody.node?.name == "invulnerability") {
                    charBullets[invulnerabilityAndCharBulletIterator].removeFromParent()
                    charBullets.remove(at: invulnerabilityAndCharBulletIterator)
                    invulnerabilityAndCharBulletIterator = invulnerabilityAndCharBulletIterator - 1
                    invulnerabilityPowerupHealth -= 1
                }
                invulnerabilityAndCharBulletIterator = invulnerabilityAndCharBulletIterator + 1
            }
            
            if(contact.bodyA.categoryBitMask == ColliderType.clearBulletCategory.rawValue) {
                seventhBody = contact.bodyA
                eightBody = contact.bodyB
            } else if (contact.bodyB.categoryBitMask == ColliderType.clearBulletCategory.rawValue){
                seventhBody = contact.bodyB
                eightBody = contact.bodyA
            }
            
            var clearBulletsAndCharBulletIterator = 0
            while(clearBulletsAndCharBulletIterator < charBullets.count) {
                if(eightBody.node == charBullets[clearBulletsAndCharBulletIterator] && seventhBody.node?.name == "clearbullets") {
                    charBullets[clearBulletsAndCharBulletIterator].removeFromParent()
                    charBullets.remove(at: clearBulletsAndCharBulletIterator)
                    clearBulletsAndCharBulletIterator = clearBulletsAndCharBulletIterator - 1
                    clearBulletsHealth = clearBulletsHealth - 1
                }
                clearBulletsAndCharBulletIterator = clearBulletsAndCharBulletIterator + 1
            }
        }
        
        if(bossBullets.count > 0) {
            //collision between character and bossbullets
            var fifthBody = SKPhysicsBody()
            var sixthBody = SKPhysicsBody()
            
            if(contact.bodyA.categoryBitMask == ColliderType.bossBulletCategory.rawValue) {
                fifthBody = contact.bodyA
                sixthBody = contact.bodyB
            } else if(contact.bodyB.categoryBitMask == ColliderType.bossBulletCategory.rawValue){
                fifthBody = contact.bodyB
                sixthBody = contact.bodyA
            }
            
            if(invulnerabilityPowerupOn == false) {
                var charAndBossBulletIterator = 0
                while(charAndBossBulletIterator < bossBullets.count) {
                    if(fifthBody.node == bossBullets[charAndBossBulletIterator] && sixthBody.node?.name == "character") {
                        bossBullets[charAndBossBulletIterator].removeFromParent()
                        bossBullets.remove(at: charAndBossBulletIterator)
                        charAndBossBulletIterator = charAndBossBulletIterator - 1
                        characterHealth = characterHealth - 1
                    }
                    charAndBossBulletIterator = charAndBossBulletIterator + 1
                }
            } else {
                perform(#selector(haveInvulnerability), with: nil, afterDelay: 4.0)
            }
        }
    }
    
    @objc func haveInvulnerability() {
        self.invulnerabilityPowerupOn = false
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
    
    @objc func bossSnowflakeAttackFire() {
        //top middle
        let bossBullet1 = SKSpriteNode(texture: bossBulletTexture)
        bossBullet1.name = "bossbullet"
        bossBullet1.physicsBody = SKPhysicsBody(texture: bossBulletTexture, size: bossBulletTexture.size())
        bossBullet1.zPosition = 1
        bossBullet1.physicsBody!.isDynamic = true
        bossBullet1.physicsBody!.usesPreciseCollisionDetection = true
        bossBullet1.physicsBody!.affectedByGravity = false
        bossBullet1.physicsBody!.velocity = CGVector.init(dx: 0, dy: 400)
        bossBullet1.physicsBody!.categoryBitMask = ColliderType.bossBulletCategory.rawValue
        bossBullet1.physicsBody!.collisionBitMask = 0
        bossBullet1.physicsBody!.contactTestBitMask = ColliderType.characterCategory.rawValue
        bossBullet1.position = CGPoint(x: boss.position.x, y: boss.position.y - 100)
        addChild(bossBullet1)
        bossBullets.append(bossBullet1)
        
        //top right
        let bossBullet2 = SKSpriteNode(texture: bossBulletTexture)
        bossBullet2.name = "bossbullet"
        bossBullet2.physicsBody = SKPhysicsBody(texture: bossBulletTexture, size: bossBulletTexture.size())
        bossBullet2.zPosition = 1
        bossBullet2.physicsBody!.isDynamic = true
        bossBullet2.physicsBody!.usesPreciseCollisionDetection = true
        bossBullet2.physicsBody!.affectedByGravity = false
        bossBullet2.physicsBody!.velocity = CGVector.init(dx: 400, dy: 400)
        bossBullet2.physicsBody!.categoryBitMask = ColliderType.bossBulletCategory.rawValue
        bossBullet2.physicsBody!.collisionBitMask = 0
        bossBullet2.physicsBody!.contactTestBitMask = ColliderType.characterCategory.rawValue
        bossBullet2.position = CGPoint(x: boss.position.x, y: boss.position.y - 100)
        addChild(bossBullet2)
        bossBullets.append(bossBullet2)
        
        //right middle
        let bossBullet3 = SKSpriteNode(texture: bossBulletTexture)
        bossBullet3.name = "bossbullet"
        bossBullet3.physicsBody = SKPhysicsBody(texture: bossBulletTexture, size: bossBulletTexture.size())
        bossBullet3.zPosition = 1
        bossBullet3.physicsBody!.isDynamic = true
        bossBullet3.physicsBody!.usesPreciseCollisionDetection = true
        bossBullet3.physicsBody!.affectedByGravity = false
        bossBullet3.physicsBody!.velocity = CGVector.init(dx: 400, dy: 0)
        bossBullet3.physicsBody!.categoryBitMask = ColliderType.bossBulletCategory.rawValue
        bossBullet3.physicsBody!.collisionBitMask = 0
        bossBullet3.physicsBody!.contactTestBitMask = ColliderType.characterCategory.rawValue
        bossBullet3.position = CGPoint(x: boss.position.x, y: boss.position.y)
        addChild(bossBullet3)
        bossBullets.append(bossBullet3)
        
        //bottom right
        let bossBullet4 = SKSpriteNode(texture: bossBulletTexture)
        bossBullet4.name = "bossbullet"
        bossBullet4.physicsBody = SKPhysicsBody(texture: bossBulletTexture, size: bossBulletTexture.size())
        bossBullet4.zPosition = 1
        bossBullet4.physicsBody!.isDynamic = true
        bossBullet4.physicsBody!.usesPreciseCollisionDetection = true
        bossBullet4.physicsBody!.affectedByGravity = false
        bossBullet4.physicsBody!.velocity = CGVector.init(dx: 400, dy: -400)
        bossBullet4.physicsBody!.categoryBitMask = ColliderType.bossBulletCategory.rawValue
        bossBullet4.physicsBody!.collisionBitMask = 0
        bossBullet4.physicsBody!.contactTestBitMask = ColliderType.characterCategory.rawValue
        bossBullet4.position = CGPoint(x: boss.position.x, y: boss.position.y)
        addChild(bossBullet4)
        bossBullets.append(bossBullet4)
        
        //bottom middle
        let bossBullet5 = SKSpriteNode(texture: bossBulletTexture)
        bossBullet5.name = "bossbullet"
        bossBullet5.physicsBody = SKPhysicsBody(texture: bossBulletTexture, size: bossBulletTexture.size())
        bossBullet5.zPosition = 1
        bossBullet5.physicsBody!.isDynamic = true
        bossBullet5.physicsBody!.usesPreciseCollisionDetection = true
        bossBullet5.physicsBody!.affectedByGravity = false
        bossBullet5.physicsBody!.velocity = CGVector.init(dx: 0, dy: -400)
        bossBullet5.physicsBody!.categoryBitMask = ColliderType.bossBulletCategory.rawValue
        bossBullet5.physicsBody!.collisionBitMask = 0
        bossBullet5.physicsBody!.contactTestBitMask = ColliderType.characterCategory.rawValue
        bossBullet5.position = CGPoint(x: boss.position.x, y: boss.position.y)
        addChild(bossBullet5)
        bossBullets.append(bossBullet5)
        
        //bottom left
        let bossBullet6 = SKSpriteNode(texture: bossBulletTexture)
        bossBullet6.name = "bossbullet"
        bossBullet6.physicsBody = SKPhysicsBody(texture: bossBulletTexture, size: bossBulletTexture.size())
        bossBullet6.zPosition = 1
        bossBullet6.physicsBody!.isDynamic = true
        bossBullet6.physicsBody!.usesPreciseCollisionDetection = true
        bossBullet6.physicsBody!.affectedByGravity = false
        bossBullet6.physicsBody!.velocity = CGVector.init(dx: -400, dy: -400)
        bossBullet6.physicsBody!.categoryBitMask = ColliderType.bossBulletCategory.rawValue
        bossBullet6.physicsBody!.collisionBitMask = 0
        bossBullet6.physicsBody!.contactTestBitMask = ColliderType.characterCategory.rawValue
        bossBullet6.position = CGPoint(x: boss.position.x, y: boss.position.y)
        addChild(bossBullet6)
        bossBullets.append(bossBullet6)
        
        //left middle
        let bossBullet7 = SKSpriteNode(texture: bossBulletTexture)
        bossBullet7.name = "bossbullet"
        bossBullet7.physicsBody = SKPhysicsBody(texture: bossBulletTexture, size: bossBulletTexture.size())
        bossBullet7.zPosition = 1
        bossBullet7.physicsBody!.isDynamic = true
        bossBullet7.physicsBody!.usesPreciseCollisionDetection = true
        bossBullet7.physicsBody!.affectedByGravity = false
        bossBullet7.physicsBody!.velocity = CGVector.init(dx: -400, dy: 0)
        bossBullet7.physicsBody!.categoryBitMask = ColliderType.bossBulletCategory.rawValue
        bossBullet7.physicsBody!.collisionBitMask = 0
        bossBullet7.physicsBody!.contactTestBitMask = ColliderType.characterCategory.rawValue
        bossBullet7.position = CGPoint(x: boss.position.x, y: boss.position.y)
        addChild(bossBullet7)
        bossBullets.append(bossBullet7)
        
        //top left
        let bossBullet8 = SKSpriteNode(texture: bossBulletTexture)
        bossBullet8.name = "bossbullet"
        bossBullet8.physicsBody = SKPhysicsBody(texture: bossBulletTexture, size: bossBulletTexture.size())
        bossBullet8.zPosition = 1
        bossBullet8.physicsBody!.isDynamic = true
        bossBullet8.physicsBody!.usesPreciseCollisionDetection = true
        bossBullet8.physicsBody!.affectedByGravity = false
        bossBullet8.physicsBody!.velocity = CGVector.init(dx: -400, dy: 400)
        bossBullet8.physicsBody!.categoryBitMask = ColliderType.bossBulletCategory.rawValue
        bossBullet8.physicsBody!.collisionBitMask = 0
        bossBullet8.physicsBody!.contactTestBitMask = ColliderType.characterCategory.rawValue
        bossBullet8.position = CGPoint(x: boss.position.x, y: boss.position.y)
        addChild(bossBullet8)
        bossBullets.append(bossBullet8)
    }
    
   @objc func spawnInvulnerabilityPowerup() {
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
        isInvulnerabilityOnScreen = true
        addChild(invulnerabilityPowerup)
        
        let invulnerabilityPath = UIBezierPath()
        invulnerabilityPath.move(to: CGPoint(x: character.position.x + 500, y: character.position.y + 350))
        invulnerabilityPath.addLine(to: CGPoint(x: -500, y: 420))
        let invulnerabilityMove = SKAction.follow(invulnerabilityPath.cgPath, asOffset: false, orientToPath: false, speed: 90)
        invulnerabilityPowerup.run(invulnerabilityMove)
    }
    
    @objc func spawnClearBulletsPowerup() {
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
        isClearBulletsOnScreen = true
        addChild(clearBulletsPowerup)
        
        let clearBulletsPath = UIBezierPath()
        clearBulletsPath.move(to: CGPoint(x: character.position.x - 600, y: character.position.y + 350))
        clearBulletsPath.addLine(to: CGPoint(x: 600, y: 420))
        let clearBulletsMove = SKAction.follow(clearBulletsPath.cgPath, asOffset: false, orientToPath: false, speed: 90)
        clearBulletsPowerup.run(clearBulletsMove)
    }
    
    func checkBossBulletsOOB() {
        //out of bounds at the bottom
        var iterator = 0
        while(iterator < bossBullets.count) {
            if(bossBullets[iterator].position.y < -700) {
                bossBullets[iterator].removeFromParent()
                bossBullets.remove(at: iterator)
                iterator = iterator - 1
                bulletsDodgedThisGame = bulletsDodgedThisGame + 1
            }
            iterator = iterator + 1
        }
        //out of bounds at the right
        var iterator2 = 0
        while(iterator2 < bossBullets.count) {
            if(bossBullets[iterator2].position.x > 700) {
                bossBullets[iterator2].removeFromParent()
                bossBullets.remove(at: iterator2)
                iterator2 = iterator2 - 1
                bulletsDodgedThisGame = bulletsDodgedThisGame + 1
            }
            iterator2 = iterator2 + 1
        }
        //out of bounds at the left
        var iterator3 = 0
        while(iterator3 < bossBullets.count) {
            if(bossBullets[iterator3].position.x < -400) {
                bossBullets[iterator3].removeFromParent()
                bossBullets.remove(at: iterator3)
                iterator3 = iterator3 - 1
                bulletsDodgedThisGame = bulletsDodgedThisGame + 1
            }
            iterator3 = iterator3 + 1
        }
    }
    
    func checkCharBulletsOOB() {
        var iterator = 0
        while(iterator < charBullets.count) {
            if(charBullets[iterator].position.y > self.size.height/4 + 320) {
                charBullets[iterator].removeFromParent()
                charBullets.remove(at: iterator)
                iterator = iterator - 1
            }
            iterator = iterator + 1
        }
    }
    
    func checkClearBulletsPowerupHealth() {
        if(clearBulletsHealth == 0 && isClearBulletsOnScreen == true) {
            clearBulletsPowerup.removeFromParent()
            var iterator = 0
            while(iterator < bossBullets.count) {
                bossBullets[iterator].removeFromParent()
                bossBullets.remove(at: iterator)
                iterator = iterator + 1
            }
            isClearBulletsOnScreen = false
        }
    }
    
    func checkClearBulletsPowerupOOB() {
        if(clearBulletsPowerup.position.x > 460 && isClearBulletsOnScreen == true) {
            clearBulletsPowerup.removeFromParent()
            isClearBulletsOnScreen = false
        }
    }
    
    func checkInvulnerabilityPowerupHealth() {
        if(invulnerabilityPowerupHealth == 0 && isInvulnerabilityOnScreen == true) {
            invulnerabilityPowerup.removeFromParent()
            invulnerabilityPowerupOn = true
            isInvulnerabilityOnScreen = false
        }
    }
    
    func checkInvulnerabilityPowerupOOB() {
        if(invulnerabilityPowerup.position.x < -490 && isInvulnerabilityOnScreen == true) {
            invulnerabilityPowerup.removeFromParent()
            isInvulnerabilityOnScreen = false
        }
    }
    
   @objc func crossAttack() {
        //top middle
        let bossBullet1 = SKSpriteNode(texture: bossBulletTexture)
        bossBullet1.name = "bossbullet"
        bossBullet1.physicsBody = SKPhysicsBody(texture: bossBulletTexture, size: bossBulletTexture.size())
        bossBullet1.zPosition = 1
        bossBullet1.physicsBody!.isDynamic = true
        bossBullet1.physicsBody!.usesPreciseCollisionDetection = true
        bossBullet1.physicsBody!.affectedByGravity = false
        bossBullet1.physicsBody!.velocity = CGVector.init(dx: 0, dy: 400)
        bossBullet1.physicsBody!.categoryBitMask = ColliderType.bossBulletCategory.rawValue
        bossBullet1.physicsBody!.collisionBitMask = 0
        bossBullet1.physicsBody!.contactTestBitMask = ColliderType.characterCategory.rawValue
        bossBullet1.position = CGPoint(x: boss.position.x, y: boss.position.y - 100)
        addChild(bossBullet1)
        bossBullets.append(bossBullet1)
        
        //right middle
        let bossBullet2 = SKSpriteNode(texture: bossBulletTexture)
        bossBullet2.name = "bossbullet"
        bossBullet2.physicsBody = SKPhysicsBody(texture: bossBulletTexture, size: bossBulletTexture.size())
        bossBullet2.zPosition = 1
        bossBullet2.physicsBody!.isDynamic = true
        bossBullet2.physicsBody!.usesPreciseCollisionDetection = true
        bossBullet2.physicsBody!.affectedByGravity = false
        bossBullet2.physicsBody!.velocity = CGVector.init(dx: 400, dy: 0)
        bossBullet2.physicsBody!.categoryBitMask = ColliderType.bossBulletCategory.rawValue
        bossBullet2.physicsBody!.collisionBitMask = 0
        bossBullet2.physicsBody!.contactTestBitMask = ColliderType.characterCategory.rawValue
        bossBullet2.position = CGPoint(x: boss.position.x, y: boss.position.y)
        addChild(bossBullet2)
        bossBullets.append(bossBullet2)
        
        //bottom middle
        let bossBullet3 = SKSpriteNode(texture: bossBulletTexture)
        bossBullet3.name = "bossbullet"
        bossBullet3.physicsBody = SKPhysicsBody(texture: bossBulletTexture, size: bossBulletTexture.size())
        bossBullet3.zPosition = 1
        bossBullet3.physicsBody!.isDynamic = true
        bossBullet3.physicsBody!.usesPreciseCollisionDetection = true
        bossBullet3.physicsBody!.affectedByGravity = false
        bossBullet3.physicsBody!.velocity = CGVector.init(dx: 0, dy: -400)
        bossBullet3.physicsBody!.categoryBitMask = ColliderType.bossBulletCategory.rawValue
        bossBullet3.physicsBody!.collisionBitMask = 0
        bossBullet3.physicsBody!.contactTestBitMask = ColliderType.characterCategory.rawValue
        bossBullet3.position = CGPoint(x: boss.position.x, y: boss.position.y)
        addChild(bossBullet3)
        bossBullets.append(bossBullet3)
        
        //left middle
        let bossBullet4 = SKSpriteNode(texture: bossBulletTexture)
        bossBullet4.name = "bossbullet"
        bossBullet4.physicsBody = SKPhysicsBody(texture: bossBulletTexture, size: bossBulletTexture.size())
        bossBullet4.zPosition = 1
        bossBullet4.physicsBody!.isDynamic = true
        bossBullet4.physicsBody!.usesPreciseCollisionDetection = true
        bossBullet4.physicsBody!.affectedByGravity = false
        bossBullet4.physicsBody!.velocity = CGVector.init(dx: -400, dy: 0)
        bossBullet4.physicsBody!.categoryBitMask = ColliderType.bossBulletCategory.rawValue
        bossBullet4.physicsBody!.collisionBitMask = 0
        bossBullet4.physicsBody!.contactTestBitMask = ColliderType.characterCategory.rawValue
        bossBullet4.position = CGPoint(x: boss.position.x, y: boss.position.y)
        addChild(bossBullet4)
        bossBullets.append(bossBullet4)
    }
    
    func doLinearPath() {
        let bossLinearPath = UIBezierPath()
        bossLinearPath.move(to: CGPoint(x: 0, y: self.size.height/4))
        bossLinearPath.addLine(to: CGPoint(x: 310, y: self.size.height/4))
        bossLinearPath.addLine(to: CGPoint(x: -280, y: self.size.height/4))
        bossLinearPath.addLine(to: CGPoint(x: 0, y: self.size.height/4))
        let bossLinearMove = SKAction.follow(bossLinearPath.cgPath, asOffset: false, orientToPath: false, speed: 150)
        boss.run(SKAction.repeat(bossLinearMove, count: 3))
    }
    
    func doHourGlassPath() {
        let bossHourglassPath = UIBezierPath()
        bossHourglassPath.move(to: CGPoint(x: 0, y: self.size.height/4))
        bossHourglassPath.addLine(to: CGPoint(x: -190, y: self.size.height/4 - 350))
        bossHourglassPath.addLine(to: CGPoint(x: -190, y: 400))
        bossHourglassPath.addLine(to: CGPoint(x: 300, y: self.size.height/4 - 350))
        bossHourglassPath.addLine(to: CGPoint(x: 300, y: 400))
        bossHourglassPath.addLine(to: CGPoint(x:0 , y: self.size.height/4))
        let bossHourglassMove = SKAction.follow(bossHourglassPath.cgPath, asOffset: false, orientToPath: false, speed: 150)
        boss.run(SKAction.repeat(bossHourglassMove, count: 3))
    }
    
    func doMiniCirclePath() {
        let bossMiniCirclePath = UIBezierPath()
        bossMiniCirclePath.move(to: CGPoint(x: 0, y: self.size.height/4 - 100))
        bossMiniCirclePath.addLine(to: CGPoint(x: 200, y: self.size.height/4 - 100))
        bossMiniCirclePath.addLine(to: CGPoint(x: -100, y: self.size.height/4 - 100))
        bossMiniCirclePath.addLine(to: CGPoint(x: 0, y: self.size.height/4 - 100))
        bossMiniCirclePath.addArc(withCenter: CGPoint(x: 0, y: self.size.height/4 - 100), radius: 80, startAngle: 0.0, endAngle: 360, clockwise: true)
        let bossMiniCircleMove = SKAction.follow(bossMiniCirclePath.cgPath, asOffset: false, orientToPath: false, speed: 150)
        boss.run(SKAction.repeat(bossMiniCircleMove, count: 3))
    }
    
    func winGame() {
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Character", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        newUser.setValue(bulletsDodgedThisGame, forKey: "totalBulletsDodged")
        newUser.setValue(bulletsFiredThisGame, forKey: "totalBulletsFired")
        //add one to totalWins in Core Data
        viewController?.performSegue(withIdentifier: "SegueFromPlayViewToEndView", sender: nil)
    }
    
    func loseGame() {
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Character", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        newUser.setValue(bulletsDodgedThisGame, forKey: "totalBulletsDodged")
        newUser.setValue(bulletsFiredThisGame, forKey: "totalBulletsFired")
        //add one to totalLosses in Core Data
        viewController?.performSegue(withIdentifier: "SegueFromPlayViewToEndView", sender: nil)
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
        bulletsFiredThisGame = bulletsFiredThisGame + 1
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
        checkBossBulletsOOB()
        checkCharBulletsOOB()
        checkClearBulletsPowerupHealth()
        checkClearBulletsPowerupOOB()
        checkInvulnerabilityPowerupHealth()
        checkInvulnerabilityPowerupOOB()
       if(characterHealth == 0 && gameOver == false) {
            gameOver = true
            loseGame()
        }
        if(bossHealth == 0 && gameOver == false) {
            gameOver = true
            winGame()
        }
        
        //self.perform(#selector(spawnClearBulletsPowerup), with: nil, afterDelay: 2.0)
    }
}


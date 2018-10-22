//
//  StatisticsScene.swift
//  Adept Fantasia
//
//  Created by Alexander Hall on 10/11/18.
//  Copyright © 2018 Hall Inc. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreData

class StatisticsScene: SKScene {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func didMove(to view: SKView) {
        
        /*let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Character")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
            print((data.value(forKey: "coreDataTest") as! String) + " is the value in the coreDataTest attribute!")
            }
        } catch {
            print("Failed")*/
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
    }
}


//
//  EndViewController.swift
//  Adept Fantasia
//
//  Created by Alexander Hall on 10/1/18.
//  Copyright © 2018 Hall Inc. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreData

class StatisticsViewController: UIViewController {
    
    @IBOutlet weak var totalBulletsDodged: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            
            // Load the SKScene from 'EndScene.sks'
            if let scene = SKScene(fileNamed: "StatisticsScene") {
                
                scene.backgroundColor = SKColor.black
                
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            //displayed total bullets dodged
            do {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Character")
                request.returnsObjectsAsFaults = false
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    totalBulletsDodged.textColor = UIColor.cyan
                    totalBulletsDodged.text = "Total Bullets Dodged: \(data.value(forKey: "totalBulletsDodged"))"
                    //print(data.value(forKey: "totalBulletsDodged"))
                   // print("OK")
                }
            } catch {
                print("Failed")
            }
            
            //display times played
            do {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Character")
                request.returnsObjectsAsFaults = false
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    totalBulletsDodged.textColor = UIColor.cyan
                    totalBulletsDodged.text = "Times Played: \(data.value(forKey: "timesPlayed"))"
                    //print(data.value(forKey: "timesPlayed"))
                    // print("OK")
                }
            } catch {
                print("Failed")
            }
            
            //display total wins
            do {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Character")
                request.returnsObjectsAsFaults = false
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    totalBulletsDodged.textColor = UIColor.cyan
                    totalBulletsDodged.text = "Total Wins: \(data.value(forKey: "totalWins"))"
                    // print("OK")
                }
            } catch {
                print("Failed")
            }
            
            //displayed total losses
            do {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Character")
                request.returnsObjectsAsFaults = false
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    totalBulletsDodged.textColor = UIColor.cyan
                    totalBulletsDodged.text = "Total Losses: \(data.value(forKey: "totalLosses"))"
                    // print("OK")
                }
            } catch {
                print("Failed")
            }
            
        }
    }
    
    @IBAction func goToHomeView(_ sender: Any) {
        self.performSegue(withIdentifier: "SegueToHomeView", sender: nil)
        //self.dismiss(animated: true, completion: nil)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}




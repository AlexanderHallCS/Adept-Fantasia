//
//  PlayViewController.swift
//  Adept Fantasia
//
//  Created by Alexander Hall on 10/1/18.
//  Copyright © 2018 Hall Inc. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

//MUST CLICK THE RECTANGLE BAR ON TOP OF THE VIEWCONTROLLER IN STORYBOARD(with first responder and exit) TO TYPE IN THE CLASS NAME INTO CUSTOM CLASS
class PlayViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if let view = self.view as! SKView? {
            
            //NEED a PlayScene.SKS file to run vvv!!!!
            // Load the SKScene from 'PlayScene.sks'
            if let scene = SKScene(fileNamed: "PlayScene") {
                
                scene.backgroundColor = SKColor.red
                
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    @IBAction func SegueToEndViewButton(_ sender: Any) {
        self.performSegue(withIdentifier: "SegueFromPlayViewToEndView", sender: nil)
        //NOT RUNNING
        print("ran!")
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


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

class EndViewController: UIViewController {
    
    var someData = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //successfully changes the value of "someData" to "lebronjames" when the segue is performed
       // print(someData)
        
        if let view = self.view as! SKView? {
            
            // Load the SKScene from 'EndScene.sks'
            if let scene = SKScene(fileNamed: "EndScene") {
                
                scene.backgroundColor = SKColor.green
                
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
    @IBAction func PlayAgainButton(_ sender: Any) {
        self.performSegue(withIdentifier: "SegueFromEndViewtoPlayView", sender: nil)
        audioPlayer.stop()
        audioPlayer.currentTime = 0;
        audioPlayer.play()
    }
    @IBAction func goToHomeView(_ sender: Any) {
        self.performSegue(withIdentifier: "goToHomeViewFromEndView", sender: nil)
    }
    
    /*@IBAction func unwindToHomeView(unwindSegue: UIStoryboardSegue) {
        
    } */
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



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
import AVFoundation
import CoreData

var audioPlayer = AVAudioPlayer()

class PlayViewController: UIViewController {
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Aaron_Smith_Ft_Luvli_Dancin_Krono_Remix_ostofmydays_(mp3co.biz)", ofType: "mp3")!))
            audioPlayer.prepareToPlay()
        }
        catch {
            print("The audio file was not found!")
        }
       
        audioPlayer.play()
        
        if let view = self.view as! SKView? {
            
            // Load the SKScene from 'PlayScene.sks'
            if let scene = SKScene(fileNamed: "PlayScene") {
                
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
            
                viewController = self
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
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


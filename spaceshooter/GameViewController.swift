//
//  GameViewController.swift
//  spaceshooter
//
//  Created by 90303054 on 2/12/20.
//  Copyright © 2020 90303054. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit

class GameViewController: UIViewController, GKGameCenterControllerDelegate {
    
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        GameCenter.shared.viewController = self
        NotificationCenter.default.addObserver(self, selector: #selector(showLeaderboard), name: NSNotification.Name(rawValue: "showLeaderboard"), object: nil)
        if let view = self.view as! SKView? {
                // Load the SKScene from 'GameScene.sks'
            let store = UserDefaults.standard
            store.setValue(nil, forKey: "Score")
                if let scene = SKScene(fileNamed: "Start") {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFill
                    
                    // Present the scene
                    view.presentScene(scene)
                }
                
                view.ignoresSiblingOrder = true
                view.showsPhysics = false
                view.showsFPS = false
                view.showsNodeCount = false
                
            }
    }

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func showLeaderboard(){
       
        let gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = GKGameCenterViewControllerState.leaderboards
        gcViewController.leaderboardIdentifier = "edu.nathaniel.spacegame.leaderboard"
        self.showDetailViewController(gcViewController, sender: self)
        self.navigationController?.pushViewController(gcViewController, animated: true)
        self.present(gcViewController, animated: true, completion: nil)
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

    override var prefersStatusBarHidden: Bool {
        return true
    }
}


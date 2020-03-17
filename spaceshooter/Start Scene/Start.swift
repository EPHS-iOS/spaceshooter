//
//  Start.swift
//  spaceshooter
//
//  Created by 90303054 on 3/4/20.
//  Copyright © 2020 90303054. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class Start: SKScene{
    
    
    var canShowLeaderboardButton = false
    lazy var startbutton = FancyButton(imageNamed: "buttonBlue", buttonAction: {
        self.transition()
    }, size: CGSize(width: 666, height: 117), alpha: 1.0)
    var scoretext = SKLabelNode()
    var leadertext: SKLabelNode = {
        let label = SKLabelNode(text: "Leaderboard")
        label.fontColor = UIColor.black
        label.fontName = "CourierNewPS-BoldMT"
        label.fontSize = 48.0
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        return label
    }()
    var starttext: SKLabelNode = {
        let label = SKLabelNode(text: "Start Game")
        label.fontColor = UIColor.black
        label.fontName = "CourierNewPS-BoldMT"
        label.fontSize = 48.0
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        return label
    }()
    lazy var leaderboardbutton = FancyButton(imageNamed: "buttonBlue", buttonAction: {
        if self.canShowLeaderboardButton {
          NotificationCenter.default.post(name: Notification.Name("showLeaderboard"), object: nil)
        } else {
            let alert = UIAlertController(title: "Game Center not connected!", message: "Game Center has not authenticated you yet" , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }, size: CGSize(width: 666, height: 117), alpha: 1.0)
    override func sceneDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(enableLeaderboardButton), name: NSNotification.Name(rawValue: "authenticated"), object: nil)
        scoretext = self.childNode(withName: "scorelabel") as! SKLabelNode
        startbutton.addChild(starttext)
        leaderboardbutton.addChild(leadertext)
        leaderboardbutton.position = CGPoint(x: 0, y: -100)
        startbutton.position = CGPoint(x: 0, y: 100)
        self.addChild(leaderboardbutton)
        self.addChild(startbutton)
        
        let store = UserDefaults.standard
        let score = store.value(forKey: "Score")
        if score != nil {
            scoretext.text = "Your score was: \(score ?? 0)"
        }
        
        
    }
    @objc func enableLeaderboardButton(){
        canShowLeaderboardButton = true
    }
    
    func transition(){
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view {
                    view.presentScene(sceneNode, transition: .crossFade(withDuration: 1.0))
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = false
                    view.showsNodeCount = false
                    view.showsPhysics = false
                }
            }
        }
    }

    
}

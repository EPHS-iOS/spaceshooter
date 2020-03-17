//
//  GameCenter.swift
//  spaceshooter
//
//  Created by 90303054 on 3/13/20.
//  Copyright © 2020 90303054. All rights reserved.
//

import GameKit
import UIKit

class GameCenter {
    
    static let shared = GameCenter()
    var viewController: UIViewController?
    var isAuthenticated = false
    
    private init() {
        GKLocalPlayer.local.authenticateHandler = { gcAuthVC, error in
            if GKLocalPlayer.local.isAuthenticated {
                self.isAuthenticated = true
               print("Authenticated to Game Center")
            } else if let vc = gcAuthVC {
                self.viewController?.present(vc, animated: true)
            } else {
                print("Error connecting to Game Center")
            }
            
            
        }
        
        
    }
 
    func updateScore(value: Int) {
        let score = GKScore(leaderboardIdentifier: "edu.nathaniel.spacegame.leaderboard")
        score.value = Int64(value)
        GKScore.report([score]) { (error) in
            if error != nil {
                print("Score update: \(error!)")
            }
        }
        
    }
  
}

  

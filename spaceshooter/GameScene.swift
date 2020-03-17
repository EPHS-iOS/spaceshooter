//
//  GameScene.swift
//  spaceshooter
//
//  Created by 90303054 on 2/12/20.
//  Copyright © 2020 90303054. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit

class GameScene: SKScene, SKPhysicsContactDelegate  {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    var ship = Ship()
    var joystick = TLAnalogJoystick(withDiameter: 250)
    lazy var firebutton = FancyButton(imageNamed: "shadedDark11.png", buttonAction: {
        //self.ship.firebullet(imagename: "laserBlue01.png")
    }, size: CGSize(width: 250, height: 250), alpha: 0.5)
    var healthtext = SKLabelNode()
    var scorelabel = SKLabelNode()
    var isTracking = false
    var firelabel: SKLabelNode = {
        var label = SKLabelNode(text: "FIRE")
        label.fontColor = UIColor.white
        label.fontName = "CourierNewPS-BoldMT"
        label.fontSize = 36
        label.verticalAlignmentMode = .center
        return label
    }()
    var enemylist = [Ship]()
    var healthkitlist = [SKSpriteNode]()
    var score = 0 {
        didSet{
            GameCenter.shared.updateScore(value: score)
        }
    }
    
    let fireeffect1 = SKSpriteNode(imageNamed: "fire03.png")
    let fireeffect2 = SKSpriteNode(imageNamed: "fire03.png")
    override func sceneDidLoad() {
        
        ship = Ship(texture: SKTexture(imageNamed: "playerShip1_blue.png"), isPlayer: true)
        ship.zPosition = 1
        //Importing sprites from GameScene.sks
        healthtext = camera?.childNode(withName: "health") as! SKLabelNode
        scorelabel = camera?.childNode(withName: "scorelabel") as! SKLabelNode
        
        joystick.handleImage = UIImage(named: "shadedDark01.png")
        joystick.baseImage = UIImage(named: "shadedDark07.png")
        joystick.alpha = 0.5
        let deviceWidth = UIScreen.main.bounds.width
        let deviceHeight = UIScreen.main.bounds.height
        if UIDevice.current.userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2688, 2436, 1792:
                //HUD positioning for all non home button iPhones
                healthtext.position = CGPoint(x: -deviceWidth * 0.8, y: deviceHeight * 0.8)
                firebutton.position = CGPoint(x: deviceWidth  * 0.5, y: -deviceHeight * 0.5)
                joystick.position = CGPoint(x: -deviceWidth * 0.5 , y: -deviceHeight * 0.5)
                ship.healthbar.position = CGPoint(x: -deviceWidth * 0.8, y: deviceHeight * 0.75)
                scorelabel.position = CGPoint(x: deviceWidth * 0.8, y: deviceHeight * 0.8)
            default:
                //HUD positioning for home button iPhones
                healthtext.position = CGPoint(x: -deviceWidth, y: deviceHeight)
                firebutton.position = CGPoint(x: deviceWidth - 100, y: -deviceHeight + 150)
                joystick.position = CGPoint(x: -deviceWidth + 100, y: -deviceHeight + 150)
                ship.healthbar.position = CGPoint(x: -deviceWidth, y: deviceHeight - 50)
                scorelabel.position = CGPoint(x: deviceWidth, y: deviceHeight)
            }
        } else {
            //HUD positioning for iPad
            switch UIScreen.main.nativeBounds.height{
            case 2732:
                healthtext.position = CGPoint(x: -deviceWidth + 300, y: deviceHeight - 300)
                firebutton.position = CGPoint(x: deviceWidth - 500, y: -deviceHeight + 400)
                joystick.position = CGPoint(x: -deviceWidth + 500, y: -deviceHeight + 400)
                ship.healthbar.position = CGPoint(x: -deviceWidth + 300, y: deviceHeight - 350)
                scorelabel.position = CGPoint(x: deviceWidth - 300, y: deviceHeight - 300)
            default:
                healthtext.position = CGPoint(x: -deviceWidth + 100, y: deviceHeight - 150)
                firebutton.position = CGPoint(x: deviceWidth - 200, y: -deviceHeight + 300)
                joystick.position = CGPoint(x: -deviceWidth + 200, y: -deviceHeight + 300)
                ship.healthbar.position = CGPoint(x: -deviceWidth + 100, y: deviceHeight - 200)
                scorelabel.position = CGPoint(x: deviceWidth - 100, y: deviceHeight - 150)
                
            }
            
            
        }
        camera?.addChild(joystick)
        camera?.addChild(ship.healthbar)
        // Show fire effect on ship
        
        fireeffect1.position = CGPoint(x: -25, y: -45)
        fireeffect2.position = CGPoint(x: 25, y: -45)
        fireeffect1.zRotation = CGFloat.pi
        fireeffect2.zRotation = CGFloat.pi
        fireeffect1.isHidden = true
        fireeffect2.isHidden = true
        ship.addChild(fireeffect1)
        ship.addChild(fireeffect2)
        //Joystick movement handlers
        joystick.on(.move) { [unowned self] joystick in
            self.isTracking = true
            self.fireeffect1.isHidden = false
            self.fireeffect2.isHidden = false
        }
        joystick.on(.end) { [unowned self] joystick in
            self.isTracking = false
            self.fireeffect1.isHidden = true
            self.fireeffect2.isHidden = true
        }
        
        physicsWorld.contactDelegate = self
        self.addChild(ship)
        camera?.addChild(firebutton)
        firebutton.addChild(firelabel)
        // Initially spawn enemies
        for _ in 0 ..< 5 {
            spawnenemy()
        }
        //Enemy spawning
        let createenemies = SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.spawnenemy()
            } , SKAction.wait(forDuration: 5.0)]))
        self.run(createenemies)
        //health pack spawning
        let createpowerups = SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.spawnhealthkit()
            } , SKAction.wait(forDuration: 10.0)]))
        self.run(createpowerups)
        
        //Creating rectangle level border
        let rect = CGRect(origin: CGPoint(x: -2500, y: -2500), size: CGSize(width: 5000, height: 5000))
        let borderindicator = SKShapeNode(rect: rect)
        borderindicator.lineWidth = 50
        borderindicator.alpha = 0.5
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
        self.addChild(borderindicator)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        guard let touchlocation = touches.first?.location(in: (camera)!) else {return}
        //        if firebutton.contains(touchlocation) {
        //            ship.firebullet(imagename: "laserBlue01.png")
        //        }
        
    }
    
    func canSpawn(position: CGPoint) -> Bool {
        for node in self.children {
            let xDist = position.x - node.position.x
            let yDist = position.y - node.position.y
            let Dist = sqrt(xDist * xDist + yDist * yDist)
            switch node.name {
            case "meteor", "enemy" :
                if Dist < 200 {
                 return false
                }
            case "player" :
                if Dist < 300 {
                return false
                }
            default: break
            }
        }
        return true
    }
    func spawnenemy() {
        
        let enemy = Ship(texture: SKTexture(imageNamed: "enemyRed1.png"), isPlayer: false)
        enemy.position = CGPoint(x: Int.random(in: -2500 ... 2500), y: Int.random(in: -2500 ... 2500))
        enemy.healthbar.position = CGPoint(x: enemy.position.x-(enemy.size.width/2), y: enemy.position.y-60)
        if canSpawn(position: enemy.position) {
        self.addChild(enemy)
        self.addChild(enemy.healthbar)
        self.enemylist.append(enemy)
        } else {
            spawnenemy()
        }
        
    }
    func spawnhealthkit(){
        
        if self.healthkitlist.count <= 5 {
            let healthkit = SKSpriteNode(imageNamed: "pill_blue.png")
            healthkit.position = CGPoint(x: Int.random(in: -2300 ... 2300), y: Int.random(in: -2300 ... 2300))
            healthkit.xScale = 3
            healthkit.yScale = 3
            if canSpawn(position: healthkit.position) {
            self.healthkitlist.append(healthkit)
            self.addChild(healthkit)
            } else {
                spawnhealthkit()
            }
            
        }
    }
    func didBegin(_ contact: SKPhysicsContact) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        
        if contact.bodyA.node?.name == "bullet" || contact.bodyB.node?.name == "bullet"{
            switch contact.bodyA.node?.name {
            case "bullet" :
                switch contact.bodyB.node?.name {
                case "bullet" : break //Contact between bullet and bullet
                    
                case "enemy" : // Contact between bullet and enemy
                    generator.impactOccurred()
                    let enemyship = contact.bodyB.node as! Ship
                    if enemyship.takeDamage(damage: 25) {
                        score += 1
                        updatescore()
                    }
                    contact.bodyA.node?.removeFromParent()
                case "player" : //Contact between bullet and player
                    generator.impactOccurred()
                    let ship = contact.bodyB.node as! Ship
                    if ship.takeDamage(damage: 1){
                        die()
                    }
                    contact.bodyA.node?.removeFromParent()
                default: contact.bodyA.node?.removeFromParent() // Contact between bullet and other object
                }
            case "enemy" : //Contact between bullet and enemy
                generator.impactOccurred()
                let enemyship = contact.bodyA.node as! Ship
                if enemyship.takeDamage(damage: 25) {
                    score += 1
                    updatescore()
                }
                contact.bodyB.node?.removeFromParent()
            case "player" : // Contact between bullet and player
                generator.impactOccurred()
                let ship = contact.bodyA.node as! Ship
                if ship.takeDamage(damage: 10){
                    die()
                }
                contact.bodyB.node?.removeFromParent()
            default:  contact.bodyB.node?.removeFromParent() //Contat between bullet and other object
            }
            
            
        }
        
    }
    
    func updatescore(){
        scorelabel.text = "Score: \(score)"
    }
    func die(){
        //Presents menu screen on player death and stores score variable
        let store = UserDefaults.standard
        store.setValue(score, forKey: "Score")
        let startScene = GameScene(fileNamed: "Start")
        startScene?.scaleMode = .aspectFill
        let reveal = SKTransition.fade(withDuration: 2)
        view!.presentScene(startScene!, transition: reveal)
    }
    
    override func update(_ currentTime: TimeInterval) {
        //Checks if player takes health kit
        for (i, healthkit) in healthkitlist.enumerated().reversed() {
            if healthkit.contains(ship.position) {
                ship.heal(damage: 20)
                healthkitlist.remove(at: i)
                healthkit.removeFromParent()
            }
        }
        //Movement handling for joystick
        if isTracking == true {
            let velocity = joystick.velocity
            let multiplier = CGFloat(0.20)
            self.ship.position = CGPoint(x: self.ship.position.x + (velocity.x * multiplier), y: self.ship.position.y + (velocity.y * multiplier))
            self.ship.zRotation = joystick.angular
            fireeffect1.alpha = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y)) / 42
            fireeffect2.alpha = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y)) / 42
        }
        if firebutton.isPressed {
            if !ship.isShooting {
                ship.isShooting = true
            }
        } else {
            if ship.isShooting{
                ship.isShooting = false
            }
        }
        camera?.position = ship.position
        for enemy in enemylist {
            // set healthbar position to follow enemy sprite
            enemy.healthbar.position = CGPoint(x: enemy.position.x - (enemy.size.width/2), y: enemy.position.y-60)
            // Calculate distance between ship and enemy
            let xDist = ship.position.x - enemy.position.x
            let yDist = ship.position.y - enemy.position.y
            
            let Dist = sqrt(xDist * xDist + yDist * yDist)
            if Dist < 1000 {
                //Enables enemy shooting
                if !enemy.isShooting {
                    enemy.isShooting = true
                }
                //Enemy rotation to player
                if xDist < 0{
                    enemy.run(SKAction.rotate(toAngle: atan(yDist/xDist) + (CGFloat.pi/2), duration: 0.2, shortestUnitArc: true))
                } else {
                    enemy.run(SKAction.rotate(toAngle: atan(yDist/xDist) + (3 * (CGFloat.pi/2)), duration: 0.2, shortestUnitArc: true))
                }
                
            } else {
                //Turns off shooting if out of aggro range
                if enemy.isShooting {
                    enemy.isShooting = false
                }
            }
        }
    }
    
}

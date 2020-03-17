//
//  Ship.swift
//  spaceshooter
//
//  Created by 90303054 on 2/20/20.
//  Copyright © 2020 90303054. All rights reserved.
//

import Foundation
import SpriteKit
class Ship: SKSpriteNode {
    var hp = 100
    var healthbar = SKSpriteNode()
    var player = Bool()
    var isShooting = false {
        didSet{
            var shootAction = SKAction()
            if player {
                shootAction = SKAction.repeatForever(SKAction.sequence([SKAction.run {
                    self.firebullet(imagename: "laserBlue01.png")
                    }, SKAction.wait(forDuration: 0.2)]))
            } else {
                shootAction = SKAction.repeatForever(SKAction.sequence([SKAction.run {
                    self.firebullet(imagename: "laserRed01.png")
                    } , SKAction.wait(forDuration: 0.60)]))
                
            }
            
            if isShooting == true{
                self.run(shootAction, withKey: "shoot")
            } else {
                self.removeAction(forKey: "shoot")
            }
            
        }
    }
    init() {
        let defaulttexture = SKTexture(imageNamed: "playerShip1_blue.png")
        super.init(texture: defaulttexture, color: UIColor.clear, size: defaulttexture.size())
    }
    init(texture: SKTexture!, isPlayer: Bool){
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        healthbar.anchorPoint.x = 0
        healthbar.color = UIColor.green
        
        
        let shipphysics = SKPhysicsBody(rectangleOf: self.frame.size)
        if isPlayer{
            player = true
            healthbar.size = CGSize(width: 250, height: 50)
            shipphysics.restitution = 0
            shipphysics.friction = 1
            shipphysics.linearDamping = 1
            shipphysics.mass = 100
            self.name = "player"
        } else {
            player = false
            healthbar.size = CGSize(width: self.size.width, height: 15)
            shipphysics.mass = 10000
            shipphysics.pinned = false
            self.name = "enemy"
        }
        
        shipphysics.allowsRotation = false
        shipphysics.affectedByGravity = false
        shipphysics.contactTestBitMask = 2
        self.physicsBody = shipphysics
        
    }
    
    func heal(damage: Int) {
        if self.hp <= 100 - damage{
            self.hp += damage
        } else {
            self.hp = 100
        }
        self.updatehp()
        
        
    }
    func takeDamage(damage: Int) -> Bool {
        let damageanimation = SKAction.sequence([SKAction.colorize(with: UIColor.red , colorBlendFactor: 0.75, duration: 0.05), SKAction.colorize(with: UIColor.clear, colorBlendFactor: 0, duration: 0.05)])
        self.run(damageanimation)
        self.hp -= damage
        
        updatehp()
        if self.hp <= 0 {
            let explosion = SKEmitterNode(fileNamed: "Fire")!
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            explosion.position = self.position
            parent?.addChild(explosion)
            self.removeFromParent()
            self.healthbar.removeFromParent()
            self.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
            }
            return true
        } else {
            return false
        }
        
        
    }
    
    
    
    func updatehp(){
        healthbar.xScale = CGFloat(self.hp)/100
        if hp < 50 {
            healthbar.color = UIColor.red
        } else {
            healthbar.color = UIColor.green
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func firebullet(imagename: String){
        
        let bullet = SKSpriteNode(imageNamed: imagename)
        bullet.name = "bullet"
        bullet.position = CGPoint(x: self.position.x + (80 * cos(self.zRotation + (CGFloat.pi / 2))), y: self.position.y + (80 * sin(self.zRotation + (CGFloat.pi / 2))))
        bullet.zRotation = self.zRotation
        bullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bullet.size.width,
                                                               height: bullet.size.height))
        
        
        bullet.physicsBody!.isDynamic = true
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.contactTestBitMask = 2
        bullet.physicsBody!.restitution = 1
        scene?.addChild(bullet)
        if player{
            let vector = CGVector(dx: 50 * cos(self.zRotation + (CGFloat.pi / 2)), dy: 50 * sin(self.zRotation + (CGFloat.pi / 2)))
            bullet.physicsBody!.applyImpulse(vector)
        } else {
            let vector = CGVector(dx: 30 * cos(self.zRotation + (CGFloat.pi / 2)), dy: 30 * sin(self.zRotation + (CGFloat.pi / 2)))
            bullet.physicsBody!.applyImpulse(vector)
        }
        
        
    }
    
    
    
    
    
    
    
}

//
//  FancyButton.swift
//  spaceshooter
//
//  Created by 90303054 on 3/14/20.
//  Copyright © 2020 90303054. All rights reserved.
//

import SpriteKit

class FancyButton: SKNode {
    var button: SKSpriteNode
    var mask: SKSpriteNode
    var crop: SKCropNode
    var action: () -> Void
    var isEnabled = true
    var isPressed = false
    init(imageNamed: String, buttonAction: @escaping () -> Void, size: CGSize, alpha: CGFloat) {
        button = SKSpriteNode(imageNamed: imageNamed)
        button.size = size
        button.alpha = alpha
        mask = SKSpriteNode(color: UIColor.black, size: button.size)
        mask.alpha = 0
        
        crop = SKCropNode()
        crop.maskNode = button
        crop.zPosition = 3
        crop.addChild(mask)
        
        action = buttonAction
        
        super.init()
        button.zPosition = 0
        addChild(button)
        addChild(crop)
        isUserInteractionEnabled = true
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled{
            mask.alpha = 0.25
            isPressed = true
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled{
            for touch in touches {
                let location = touch.location(in: self)
                
                if button.contains(location){
                    mask.alpha = 0.25
                    isPressed = true
                } else {
                    mask.alpha = 0.0
                    isPressed = false
                }
            }
            
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            for touch in touches {
                let location = touch.location(in: self)
                if button.contains(location) {
                    isPressed = false
                    disable()
                    action()
                    run(SKAction.sequence([SKAction.wait(forDuration: 0.1), SKAction.run {
                        self.enable()
                        }]))
                }
            }
            
            
        }
    
    }
    func enable(){
        isEnabled = true
        mask.alpha = 0.0
        
    }
    func disable() {
        isEnabled = false
        mask.alpha = 0.0
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

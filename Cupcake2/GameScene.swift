//
//  GameScene.swift
//  Cupcake2
//
//  Created by Anne Cahalan on 3/27/15.
//  Copyright (c) 2015 Anne Cahalan. All rights reserved.
//

import CoreMotion
import SpriteKit

let kPlayerSpeed = 250
let character = SKSpriteNode(imageNamed: "daisy")

struct PhysicsCategory {
    static let character: UInt32 = 0x1 << 0
    static let cupcake: UInt32 = 0x1 << 0
    static let kale: UInt32 = 0x1 << 0 
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var score: Int = 0
    
    override init() {
        score = 0
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    // move to class
    func createCharacterNode() {
        character.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMinY(self.frame) + 100)
        character.physicsBody = SKPhysicsBody(rectangleOfSize: character.size)
        
        guard let physicsBody = character.physicsBody else { return }
        physicsBody.dynamic = false
        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.affectedByGravity = false
        physicsBody.contactTestBitMask = PhysicsCategory.character
        
        self.addChild(character)
    }
    
    // move to class
    func createCupcakeNode(){
        let cupcake = SKSpriteNode(imageNamed: "cupcake")
        
        let startingX = random(frame.minX, max: self.frame.maxX)
        
        cupcake.position = CGPoint(x: startingX, y: CGRectGetMidY(self.frame) + 250)
        cupcake.physicsBody = SKPhysicsBody(rectangleOfSize: cupcake.size)
        
        guard let physicsBody = cupcake.physicsBody else {
            print("Taking a poop")
            return
        }
        
        physicsBody.dynamic = true
        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.affectedByGravity = true;
        physicsBody.contactTestBitMask = PhysicsCategory.cupcake
        
        let spin = SKAction.rotateByAngle(CGFloat(M_PI), duration:0.25)
        
        cupcake.runAction(SKAction.repeatActionForever(spin))
        
        self.addChild(cupcake)
    }
    
    
    // maybe don't worry about this until everyone is in a class
    func createKaleNode() {
        let kale = SKSpriteNode(imageNamed: "kale")
        
        let startingX = random(frame.minX, max: self.frame.maxX)
        
        kale.position = CGPoint(x: startingX, y: CGRectGetMidY(self.frame) + 250)
        kale.physicsBody = SKPhysicsBody(rectangleOfSize: kale.size)
        
        guard let physicsBody = kale.physicsBody else {
            print("Taking a poop")
            return
        }
        
        physicsBody.dynamic = true
        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.affectedByGravity = true;
        physicsBody.contactTestBitMask = PhysicsCategory.cupcake
        
        let spin = SKAction.rotateByAngle(CGFloat(M_PI), duration:0.25)
        
        kale.runAction(SKAction.repeatActionForever(spin))
        
        self.addChild(kale)

    }
    
    override func didMoveToView(view: SKView) {
        createCharacterNode()
        
        physicsWorld.contactDelegate = self
        
        let motionManager:CMMotionManager = CMMotionManager()
        if (motionManager.accelerometerAvailable) {
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue()) {
                (data, error) in
                let currentX = character.position.x
                let currentY = character.position.y
                
                _ = CGPoint(x: CGRectGetMaxX(self.frame), y: currentY)
                _ = CGPoint(x: CGRectGetMinX(self.frame), y: currentY)
                
                guard let movementData = data else { return }
                if (movementData.acceleration.x < -0.25) { //tilts right
                    let destinationX = (CGFloat(movementData.acceleration.x) * CGFloat(kPlayerSpeed) + CGFloat(currentX))
                    let destinationY = CGFloat(currentY)
                    motionManager.accelerometerActive == true
                    let action = SKAction.moveTo(CGPointMake(destinationX, destinationY), duration: 1)
                    character.runAction(action)
                    
                }
                else if (movementData.acceleration.x > 0.25) { //tilts left
                    let destinationX = (CGFloat(movementData.acceleration.x) * CGFloat(kPlayerSpeed) + CGFloat(currentX))
                    let destinationY = CGFloat(currentY)
                    motionManager.accelerometerActive == true
                    let action = SKAction.moveTo(CGPointMake(destinationX, destinationY), duration: 1)
                    character.runAction(action)
                }
            }
        }
    
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(createCupcakeNode),
                SKAction.waitForDuration(0.05),
                SKAction.runBlock(createKaleNode),
                SKAction.waitForDuration(0.05)
                ])
            ))
    }
    
    func characterHasCaughtCupcake(cupcake:SKSpriteNode) {
        score += 10
        print("nom: \(score)")
        
        cupcake.removeFromParent()
    }
    
    func characterHasCaughtKale(kale: SKSpriteNode) {
        score -= 10
        print("EWWWW: \(score)")
        
         kale.removeFromParent()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // the Else/Kale block is not getting hit at all
        // maybe don't worry about it until we've refactored to classes 
        if (firstBody.categoryBitMask & PhysicsCategory.cupcake != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.character != 0) {
            // are we unexpectantly finding nil here? WHO WHERE WHY AAAARGH
            characterHasCaughtCupcake(firstBody.node as! SKSpriteNode)
        } else if (firstBody.categoryBitMask & PhysicsCategory.kale != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.character != 0) {
            characterHasCaughtKale(firstBody.node as! SKSpriteNode)
        }
    }
    
}

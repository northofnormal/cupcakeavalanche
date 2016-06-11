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
let scoreLabel = SKLabelNode(fontNamed: "Avenir")

let characterCategory: UInt32 = 0x1 << 1
let cupcakeCategory: UInt32 = 0x1 << 2
let kaleCategory: UInt32 = 0x1 << 3

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var score: Int = 0
    
    override init() {
        super.init()
        
        score = 0
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
        
        guard let texture = character.texture else { return }
        character.physicsBody = SKPhysicsBody(texture: texture, size: character.size)
        //SKPhysicsBody(rectangleOfSize: character.size)
        
        guard let physicsBody = character.physicsBody else { return }
        physicsBody.dynamic = false
        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.affectedByGravity = false
        physicsBody.contactTestBitMask = cupcakeCategory | kaleCategory
        physicsBody.categoryBitMask = characterCategory
        
        self.addChild(character)
    }
    
    // move to class
    func createCupcakeNode(){
        // stop moving this up to the top, you need a new cupcake each time this is called!
        let cupcake = SKSpriteNode(imageNamed: "cupcake")
        let startingX = random(frame.minX, max: self.frame.maxX)
        
        cupcake.position = CGPoint(x: startingX, y: CGRectGetMidY(self.frame) + 250)
        
        guard let texture = cupcake.texture else { return }
        cupcake.physicsBody = SKPhysicsBody(texture: texture, size: cupcake.size)
        
        guard let physicsBody = cupcake.physicsBody else {
            print("Taking a poop")
            return
        }
        
        physicsBody.dynamic = true
        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.affectedByGravity = true;
        physicsBody.contactTestBitMask = characterCategory | kaleCategory
        physicsBody.categoryBitMask = cupcakeCategory
        
        let spin = SKAction.rotateByAngle(CGFloat(M_PI), duration:0.25)
        
        cupcake.runAction(SKAction.repeatActionForever(spin))
        
        self.addChild(cupcake)
    }
    
    func createKaleNode() {
        // stop moving this to the top. You need a new kale each time it's called!
        let kale = SKSpriteNode(imageNamed: "kale")
        let startingX = random(frame.minX, max: self.frame.maxX)
        
        kale.position = CGPoint(x: startingX, y: CGRectGetMidY(self.frame) + 250)
        
        guard let texture = kale.texture else { return }
        kale.physicsBody = SKPhysicsBody(texture: texture, size: kale.size)
        
        guard let physicsBody = kale.physicsBody else {
            print("Taking a poop")
            return
        }
        
        physicsBody.dynamic = true
        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.affectedByGravity = true;
        physicsBody.contactTestBitMask = characterCategory | cupcakeCategory
        physicsBody.categoryBitMask = kaleCategory
        
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
        
        let scoreLabel = addScoreLabel()
        self.addChild(scoreLabel)
    
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(createCupcakeNode),
                SKAction.waitForDuration(0.05),
                SKAction.runBlock(createKaleNode),
                SKAction.waitForDuration(0.05)
                ])
            ))
    }
    
    func addScoreLabel() -> SKLabelNode {
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = SKColor.blackColor()
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - 25)
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        scoreLabel.text = "\(score)"
        return scoreLabel
    }
    
    func updateScoreLabel() {
        scoreLabel.text = "\(score)"
    }
    
    func characterHasCaughtCupcake(cupcake:SKSpriteNode) {
        score += 10
        updateScoreLabel()
        print("nom: \(score)")
        
        cupcake.removeFromParent()
    }
    
    func characterHasCaughtKale(kale: SKSpriteNode) {
        score -= 10
        updateScoreLabel()
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
        
        if (firstBody.categoryBitMask == characterCategory && secondBody.categoryBitMask == cupcakeCategory) {
            guard let cupcake = secondBody.node else { return }
            characterHasCaughtCupcake(cupcake as! SKSpriteNode)
            print("Caught a cupcake yay!")
        } else if (firstBody.categoryBitMask == characterCategory && secondBody.categoryBitMask == kaleCategory) {
            guard let kale = secondBody.node else { return }
            characterHasCaughtKale(kale as! SKSpriteNode)
            print("Caught kale EWWWWW")
        }
    }
    
}

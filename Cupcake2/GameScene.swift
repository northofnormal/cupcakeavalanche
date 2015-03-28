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
let cupcake = SKSpriteNode(imageNamed: "cupcake")

struct PhysicsCategory {
    static let character: UInt32 = 0x1 << 0
    static let cupcake: UInt32 = 0x1 << 0
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    func createCharacterNode() {
        character.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMinY(self.frame) + 100)
        character.physicsBody = SKPhysicsBody(rectangleOfSize: character.size)
        character.physicsBody?.dynamic = false
        character.physicsBody?.usesPreciseCollisionDetection = true
        character.physicsBody?.affectedByGravity = false
        character.physicsBody?.contactTestBitMask = PhysicsCategory.character
        
        self.addChild(character)
    }
    
    func createCupcakeNode(){
        cupcake.position = CGPoint(x: CGRectGetMidX(self.frame) - 50, y: CGRectGetMidY(self.frame) + 250)
        cupcake.physicsBody = SKPhysicsBody(rectangleOfSize: cupcake.size)
        cupcake.physicsBody?.dynamic = true
        cupcake.physicsBody?.usesPreciseCollisionDetection = true
        cupcake.physicsBody?.affectedByGravity = true;
        cupcake.physicsBody?.contactTestBitMask = PhysicsCategory.cupcake
        
        let spin = SKAction.rotateByAngle(CGFloat(M_PI), duration:0.25)
        
        cupcake.runAction(SKAction.repeatActionForever(spin))
        
        self.addChild(cupcake)
    }
    
    override func didMoveToView(view: SKView) {
        createCharacterNode()
        createCupcakeNode()
        
        physicsWorld.contactDelegate = self
        
        let motionManager:CMMotionManager = CMMotionManager()
        if (motionManager.accelerometerAvailable) {
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue()) {
                (data, error) in
                let currentX = character.position.x
                let currentY = character.position.y
                
                let maxX = CGPoint(x: CGRectGetMaxX(self.frame), y: currentY)
                let minX = CGPoint(x: CGRectGetMinX(self.frame), y: currentY)
                
                if (data.acceleration.x < -0.25) { //tilts right
                    var destinationX = (CGFloat(data.acceleration.x) * CGFloat(kPlayerSpeed) + CGFloat(currentX))
                    var destinationY = CGFloat(currentY)
                    motionManager.accelerometerActive == true
                    let action = SKAction.moveTo(CGPointMake(destinationX, destinationY), duration: 1)
                    character.runAction(action)
                }
                else if (data.acceleration.x > 0.25) { //tilts left
                    var destinationX = (CGFloat(data.acceleration.x) * CGFloat(kPlayerSpeed) + CGFloat(currentX))
                    var destinationY = CGFloat(currentY)
                    motionManager.accelerometerActive == true
                    let action = SKAction.moveTo(CGPointMake(destinationX, destinationY), duration: 1)
                    character.runAction(action)
                }
            }
        }
    }
    
    func characterHasCaughtCupcake(cupcake:SKSpriteNode) {
        println("nom")
        cupcake.removeFromParent()
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
        
        if (firstBody.categoryBitMask & PhysicsCategory.cupcake != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.character != 0) {
                characterHasCaughtCupcake(firstBody.node as SKSpriteNode)
        }
    }
    
}

//
//  GameScene.swift
//  PacyBird
//
//  Created by Levesque Frederic M. on 3/22/18.
//  Copyright © 2018 Levesque Frederic M. All rights reserved.
//

import SpriteKit
//import GameplayKit

struct PhysicsCatagory{
    
    static let Pac : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Ground = SKSpriteNode()
    var Pac = SKSpriteNode()
    
    var wallPair = SKNode()
    
    var moveAndRemove = SKAction()
    
    var gameStarted = Bool()
    
    var score = Int()
    let scoreLabel = SKLabelNode()
    
    var died = Bool()
    var restartButton = SKSpriteNode()
    
    func restartScene(){
        
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
        
    }
    
    func createScene(){
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2{
            let background = SKSpriteNode(imageNamed: "pacmanBackground")
            background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            background.position = CGPoint(x: CGFloat(i) * self.frame.width , y: 0)
            background.name = "background"
            self.addChild(background)
        }
        
        scoreLabel.position = CGPoint(x: self.frame.width / 150, y: self.frame.height / -2 + self.frame.height / 1.2)
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = "04b_19"
        scoreLabel.zPosition = 5
        scoreLabel.fontSize = 60
        
        self.addChild(scoreLabel)
        
        Ground = SKSpriteNode (imageNamed: "Ground")
        Ground.position = CGPoint(x: self.frame.width / 6, y: 0 + self.frame.height / -2.1 )
        
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCatagory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCatagory.Pac
        Ground.physicsBody?.contactTestBitMask = PhysicsCatagory.Pac
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        
        Ground.zPosition = 3
        
        self.addChild(Ground)
        
        Pac = SKSpriteNode(imageNamed: "Pacman")
        Pac.size = CGSize(width: 70, height: 80)
        Pac.position = CGPoint(x: self.frame.width / 1.5 - self.frame.width, y: self.frame.height / self.frame.height)
        
        Pac.physicsBody = SKPhysicsBody(circleOfRadius: Pac.frame.height / 2)
        Pac.physicsBody?.categoryBitMask = PhysicsCatagory.Pac
        Pac.physicsBody?.collisionBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall
        Pac.physicsBody?.contactTestBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall | PhysicsCatagory.Score
        Pac.physicsBody?.affectedByGravity = false
        Pac.physicsBody?.isDynamic = true
        
        Pac.zPosition = 2
        
        self.addChild(Pac)
        
    }
    
    override func didMove (to view: SKView){
        
        createScene()
       
    }
    
    func createButton(){
        
        restartButton = SKSpriteNode(imageNamed: "restart")
        restartButton.size = CGSize(width: 200, height: 100)
        restartButton.position = CGPoint(x: 0, y: 0)
        restartButton.zPosition = 6
        restartButton.setScale(0)
        self.addChild(restartButton)
        
        restartButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCatagory.Score && secondBody.categoryBitMask == PhysicsCatagory.Pac || firstBody.categoryBitMask == PhysicsCatagory.Pac && secondBody.categoryBitMask == PhysicsCatagory.Score {
            
            score += 1
            scoreLabel.text = "\(score)"
            
        }
        
        if firstBody.categoryBitMask == PhysicsCatagory.Wall && secondBody.categoryBitMask == PhysicsCatagory.Pac || firstBody.categoryBitMask == PhysicsCatagory.Pac && secondBody.categoryBitMask == PhysicsCatagory.Wall{
            
            enumerateChildNodes(withName: "wallPair", using: ({ (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            if died == false{
                died = true
                createButton()
            }
        }
        
        if firstBody.categoryBitMask == PhysicsCatagory.Ground && secondBody.categoryBitMask == PhysicsCatagory.Pac || firstBody.categoryBitMask == PhysicsCatagory.Pac && secondBody.categoryBitMask == PhysicsCatagory.Ground{
            
            enumerateChildNodes(withName: "wallPair", using: ({ (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            if died == false{
                died = true
                createButton()
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameStarted == false{
            
            gameStarted = true
            
            Pac.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.run({
                () in
                
                self.createWalls()
                
            })
            
            let delay = SKAction.wait(forDuration: 2.0)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width + 410)
            let moveWalls = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.005 * distance))
            let removeWalls = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([moveWalls, removeWalls])
            
            Pac.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            Pac.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200
        ))
        }
        else{
            if died == true {
                
            }
            else{
            Pac.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            Pac.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
            }
        }
        
        for touch in touches{
            
            _ = touch.location(in: self)
            if died == true {
                    restartScene()
            }
            
        }
    }
    
    func createWalls(){
        
        let scoreNode = SKSpriteNode()
        
        scoreNode.size = CGSize(width: 1, height: 500)
        scoreNode.position = CGPoint(x: self.frame.width, y: self.frame.height / 540)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCatagory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCatagory.Pac
        scoreNode.color = SKColor.blue
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let bottomWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width, y: self.frame.height / 20 + 600)
        bottomWall.position = CGPoint(x: self.frame.width, y: self.frame.height / 20 - 600)
        
        topWall.setScale(0.8)
        bottomWall.setScale(0.8)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCatagory.Pac
        topWall.physicsBody?.contactTestBitMask = PhysicsCatagory.Pac
        topWall.physicsBody?.affectedByGravity = false
        topWall.physicsBody?.isDynamic = false
        
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        bottomWall.physicsBody?.collisionBitMask = PhysicsCatagory.Pac
        bottomWall.physicsBody?.contactTestBitMask = PhysicsCatagory.Pac
        bottomWall.physicsBody?.affectedByGravity = false
        bottomWall.physicsBody?.isDynamic = false
        
        
        topWall.zRotation = CGFloat(M_PI)
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        
        wallPair.zPosition = 1
        
        var randomPosition = CGFloat.random(min: -375, max: 375)
        wallPair.position.y = wallPair.position.y + randomPosition
        wallPair.addChild(scoreNode)
        
        wallPair.run(moveAndRemove)
        
        self.addChild(wallPair)
    }
    
    override func update(_ currentTime: CFTimeInterval){
        
        if gameStarted == true{
            if died == false{
                enumerateChildNodes(withName: "background", using: ({(node, error) in
                    
                    let background = node as! SKSpriteNode
                    background.position = CGPoint(x: background.position.x - 2,y: background.position.y)
                   if background.position.x <= -background.size.width{
                    background.position = CGPoint(x: background.position.x + background.size.width * 1.8, y: background.position.y)
                    }
                }))
            }
        }
        
    }
}


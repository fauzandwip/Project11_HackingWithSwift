//
//  GameScene.swift
//  Project11
//
//  Created by Fauzan Dwi Prasetyo on 03/05/23.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var balls = ["ballRed", "ballCyan", "ballYellow", "ballGrey", "ballBlue", "ballGreen", "ballPurple"]
    
    var editLabel: SKLabelNode!
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Edit"
            } else {
                editLabel.text = "Done"
            }
        }
    }
    
    var box: SKSpriteNode!
    var ball: SKSpriteNode!
    var restart: SKLabelNode!
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var totalBalls: SKLabelNode!
    var ballLimit = 5 {
        didSet {
            totalBalls.text = "Total Balls: \(ballLimit)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Done"
        editLabel.horizontalAlignmentMode = .left
        editLabel.position = CGPoint(x: 80, y: 700)
        editLabel.zPosition = 1
        addChild(editLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        scoreLabel.zPosition = 1
        addChild(scoreLabel)
        
        totalBalls = SKLabelNode(fontNamed: "Chalkduster")
        totalBalls.text = "Total Balls: 5"
        totalBalls.horizontalAlignmentMode = .center
        totalBalls.position = CGPoint(x: 512, y: 700)
        totalBalls.zPosition = 1
        addChild(totalBalls)
        
        restart = SKLabelNode(fontNamed: "Chalkduster")
        restart.text = "Restart"
        restart.horizontalAlignmentMode = .left
        restart.position = CGPoint(x: 80, y: 650)
        restart.zPosition = 1
        addChild(restart)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            let objects = nodes(at: location)
            
            if objects.contains(editLabel) {
                editingMode.toggle()
            } else if objects.contains(restart) {
                score = 0
                ballLimit = 5
                
                self.enumerateChildNodes(withName: "box") { node, stop in
                    if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
                        fireParticles.position = node.position
                        self.addChild(fireParticles)
                    }
                    node.run(SKAction.removeFromParent())
                 }
                self.enumerateChildNodes(withName: "ball") { node, stop in
                    if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
                        fireParticles.position = node.position
                        self.addChild(fireParticles)
                    }
                    node.run(SKAction.removeFromParent())
                 }
            } else {
                if editingMode {
                    let size = CGSize(width: Int.random(in: 16...128), height: 16)
                    box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                    box.position = location
                    box.zRotation = CGFloat.random(in: 0...3)
                    box.name = "box"
                    
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    addChild(box)
                } else {
                    balls.shuffle()
                    
                    if ballLimit > 0 {
                        ballLimit -= 1
                        
                        ball = SKSpriteNode(imageNamed: balls[0])
                        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                        ball.physicsBody?.restitution = 0.4
                        ball.position = CGPoint(x: location.x, y: 740)
                        ball.name = "ball"
                        addChild(ball)
                    }
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
    
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(nodeObject: ball)
            score += 1
            ballLimit += 1
        } else if object.name == "bad" {
            destroy(nodeObject: ball)
            score -= 1
        } else if object.name == "box" {
            destroy(nodeObject: object)
        }
        
    }
    
    func destroy(nodeObject: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = nodeObject.position
            addChild(fireParticles)
        }
        
        nodeObject.removeFromParent()
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = position
            fireParticles.numParticlesToEmit = 0
            fireParticles.particleLifetime = 3
            self.addChild(fireParticles)
        }
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
                
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
}

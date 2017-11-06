//
//  SpringScene.swift
//  BreathEveryday
//
//  Created by Bomi on 2017/10/29.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import Foundation
import SpriteKit

class SpringScene: SKScene {
    
    var bgNode: SKSpriteNode!
    var imagesName = ["Bubble"]
    let nodeSize = CGSize(width: 25, height: 25)
    
    //Scene LifeCycle
    override func didMove(to view: SKView) {
        self.createSceneContents()
    }
    
    func createSceneContents() {
        self.backgroundColor = .clear
        self.scaleMode = .aspectFit
        
        self.makeHearts()
    }
    
    //#pragma mark - Sprite Node
    
    @objc func addHeartNode() {
        let node = SKSpriteNode(imageNamed: randomImageName())
        node.size = self.nodeSize;
        print("==========================================")
        print("==== \(self.frame) ==============")
        print("==== \(self.view?.frame) ==============")
        print("==== \(self.view?.superview?.frame) ==============")
        print("==========================================")
//        print(self.view?.frame)
//        print(self.view?.superview?.frame)
//        print(self.frame)
        node.position = CGPoint(x: 0.5 * self.frame.width, y: self.frame.maxY)
        node.name = "test"
        let maxY = self.frame.height
        let width = self.size.width
        var xOffset = CGFloat(arc4random_uniform(UInt32(width))) - 0.5*width
        if (xOffset < -0.5*(width-self.nodeSize.width)) {
            xOffset = -0.5*(width-self.nodeSize.width);
        }
        
        let actions = SKAction.sequence([SKAction.moveBy(x: xOffset, y: 0.5*maxY, duration: 3),
                                         SKAction.moveTo(y: maxY+10, duration: 3)])
        node.run(actions)
        self.addChild(node)
    }
    
    
    //#pragma mark - getter
    func randomImageName() -> String {
        return imagesName[Int(arc4random())%imagesName.count];
    }
    
    func makeHearts() {
        let action = SKAction.sequence([SKAction.perform(#selector(addHeartNode), onTarget: self),
                                        SKAction.wait(forDuration: 0.3, withRange: 0.2)])
//        self.run(SKAction.repeatForever(action), withKey: "test")
        self.run(action, withKey: "test")
    }
    
    override func didSimulatePhysics() {
        self.enumerateChildNodes(withName: "test") { (node, stop) in
            let maxxY = self.frame.height
            
            if node.position.y >= 0.7*maxxY {
                node.run(SKAction.fadeOut(withDuration: 1))
            }
            
            if node.position.y > maxxY {
                node.removeFromParent()
            }
            
        }
    }
}



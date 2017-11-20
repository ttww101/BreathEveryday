//
//  HomeViewController+Bubble.swift
//  BreathEveryday
//
//  Created by Bomi on 2017/9/25.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import Spring

extension HomeViewController {
    
    func createRandomBubble(with image: UIImage, in frame: CGRect?, color: UIColor) -> SpringButton {
        
        let button = SpringButton()
        
        if let frame = frame {
            button.layer.frame = frame
        } else {
            let xPos = arc4random_uniform(UInt32(view.frame.width) - 100)
            let yPos = arc4random_uniform(UInt32(colorPickerView.frame.minY) - 100 - UInt32(quoteButton.frame.maxY)) + UInt32(quoteButton.frame.maxY)
            button.layer.frame = CGRect(x: Int(xPos), y: Int(yPos), width: 84, height: 84)
        }
        
        button.normalSetup(normalImage: image,
                           selectedImage: nil,
                           tintColor: .white)
        button.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
        button.setFrameToCircle()
        button.setBubbleColor(with: color)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(dragBubble))
        button.addGestureRecognizer(gesture)
        
        return button
    }
    
    @objc func dragBubble(gesture: UIPanGestureRecognizer) {
        
        let target = gesture.view!
        var isDeleteSuccess = false
        
        var bubbleAnimator = UIViewPropertyAnimator(duration: 1.0, curve: .easeInOut, animations: { })
        //        dragAnimatorArray.append(bubbleAnimator)
        
        switch gesture.state {
        case .began:
            
            if bubbleAnimator.state == .active {
                bubbleAnimator.stopAnimation(true)
            }
            circleCenter = target.center
            bubbleAnimator.addAnimations {
                target.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
            }
            bubbleAnimator.startAnimation()
            
        case .changed:
            let translation = gesture.translation(in: self.view)
            target.center = CGPoint(x: circleCenter.x + translation.x,
                                    y: circleCenter.y + translation.y)
            
        case .ended:
            //shrink bubble
            if bubbleAnimator.state == .active {
                bubbleAnimator.stopAnimation(true)
            }
            //deceleration
            let velocity = gesture.velocity(in: view)
            let cgVelocity = CGVector(dx: velocity.x / 500, dy: velocity.y / 500)
            let springParameters = UISpringTimingParameters(mass: 2.5, stiffness: 50, damping: 25, initialVelocity: cgVelocity)
            bubbleAnimator = UIViewPropertyAnimator(duration: 0.0, timingParameters: springParameters) // original 2.5, 70, 55)
            var stopPoint_X = target.center.x + velocity.x * 0.05
            var stopPoint_Y = target.center.y + velocity.y * 0.05
            
            bubbleAnimator.addAnimations {
                
                switch self.currentMode {
                    
                case .normal:
                    
                    if 50 <= stopPoint_X && stopPoint_X <= self.view.frame.maxX - 50 &&
                        80 <= stopPoint_Y && stopPoint_Y <= self.view.frame.maxY - 50 {
                        
                        target.center = CGPoint(x: stopPoint_X, y: stopPoint_Y)
                        target.transform = CGAffineTransform.identity
                        
                    } else {
                        
                        if stopPoint_X < 50 { stopPoint_X = 35 }
                        if stopPoint_X > self.view.frame.maxX - 50 {
                            stopPoint_X = self.view.frame.maxX - 35 }
                        if stopPoint_Y < 80 { stopPoint_Y = 80 }
                        if stopPoint_Y > self.view.frame.maxY - 50 {
                            stopPoint_Y = self.view.frame.maxY - 35 }
                        target.center = CGPoint(x: stopPoint_X, y: stopPoint_Y)
                        target.transform = CGAffineTransform.identity
                        
                    }

                case .setupCategory:
                    
                    target.center = CGPoint(x: stopPoint_X, y: stopPoint_Y)
                    target.transform = CGAffineTransform.identity
                    
                    if 25 <= stopPoint_X && stopPoint_X <= self.view.frame.maxX - 25 &&
                        25 <= stopPoint_Y && stopPoint_Y <= self.view.frame.maxY - 25 {
                    } else {
                        
                        //delete bubble data
                        if let deleteRow = gesture.view?.tag {
                            
                            isDeleteSuccess = true
                            
                            let indexPath = IndexPath(row: deleteRow, section: 0)
                            DispatchQueue.main.async {
                                self.categorysCollectionView.reloadItems(at: [indexPath])
                            }
                            self.categoryDataArr[deleteRow].button.removeFromSuperview()
                            self.categoryDataArr[deleteRow].isCreated = false
                            self.categorysCollectionView.deselectItem(at: indexPath, animated: true)
                        }
                    }
                    
                default:
                    break
                }
                
            }
            bubbleAnimator.startAnimation()
            //swing animation
            if let target = target as? SpringButton {
                target.animation = "swing"
                target.curve = "easeInCubic"
                target.damping = 50
                target.velocity = 0.1
                target.force = 0.2
                target.scaleX = 0.85
                target.scaleY = 0.85
                target.duration = 2.5
                target.animate()
                target.layer.opacity = 0.6
            }
            
        default:
            break
        }
        
        //delete animation
        if isDeleteSuccess {
            alertLabel(replaceString: "Deleted", isHidden: true, color: .red)
        }
    }
    
}

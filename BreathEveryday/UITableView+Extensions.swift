//
//  UITableView+Extensions.swift
//  FeatherList
//
//  Created by Bomi on 2017/9/28.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit

extension UITableView {
    typealias cellShrinkCompletion = (TimeInterval, Int) -> Swift.Void
    typealias rotateCompletion = () -> Swift.Void
    
    func cellShrink(duration: TimeInterval, completion: @escaping cellShrinkCompletion) {
        UIView.animate(withDuration: duration, animations: {
            for i in 0...self.numberOfRows(inSection: 0) {
                let indexPath: IndexPath = IndexPath(item: i, section: 0)
                if let cell = self.cellForRow(at: indexPath) {
                    cell.layer.transform = CATransform3DMakeScale(0.3,0.3,1)
                }
            }
            completion(duration, 1)
        }) { (_) in
            
        }
    }
    
    func cellshrinkAll(duration: TimeInterval) {
        for j in 0...self.numberOfRows(inSection: 0) - 1 {
            if let cell = self.cellForRow(at: IndexPath(row: j, section: 0)) {
                UIView.animate(withDuration: duration, animations: {
                    cell.layer.transform = CATransform3DMakeScale(0,0,1)
                }, completion: { (_) in
                    
                })
            }
        }
        //        let cellCounts = self.visibleCells.count
        //        for cellRow in 0...cellCounts {
        //            let indexPath: IndexPath = IndexPath(item: cellRow, section: 0)
        //            if let cell = self.cellForRow(at: indexPath) {
        //                cell.layer.transform = CATransform3DMakeScale(0,0,1)
        //            }
        //        }
    }
    
    func rotate(duration: TimeInterval,times num: Int, completion: @escaping rotateCompletion) {
        UIView.animate(withDuration: duration, animations: {
            self.layer.transform = CATransform3DRotate(CATransform3DIdentity,           CGFloat(Double.pi)/2, 0, 1, 0)
            
        }, completion: { (_) in
            UIView.animate(withDuration: duration, animations: {
                self.layer.transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(Double.pi * 2), 0, 1, 0)
                if num == 1 {
                    for i in 0...self.numberOfRows(inSection: 0) {
                        let indexPath: IndexPath = IndexPath(item: i, section: 0)
                        if let cell = self.cellForRow(at: indexPath) {
                            cell.layer.transform = CATransform3DMakeScale(1,1,1)
                        }
                    }
                }
                completion()
                
            }, completion: { (_) in
                if num - 1 > 0 {
                    self.rotate(duration: duration,times: num - 1, completion: completion)
                } else {
                    
                }
            })
        })
        
    }
    
    func cellEmergeOrderly(from indexRow: Int) {
        if indexRow < self.numberOfRows(inSection: 0) {
            let indexPath: IndexPath = IndexPath(item: indexRow, section: 0)
            if let cell = self.cellForRow(at: indexPath) {
                cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
                UIView.animate(withDuration: 0.25, animations: {
                    cell.layer.transform = CATransform3DMakeScale(1.1,1.1,1)
                },completion: { finished in
                    UIView.animate(withDuration: 0.1, animations: {
                        cell.layer.transform = CATransform3DMakeScale(1,1,1)
                    })
                    self.cellEmergeOrderly(from: indexRow + 1)
                })
            }
        }
    }
    
    func cellDismissAll(duration: TimeInterval) {
        UIView.animate(withDuration: 3, animations: {
            for i in 0...self.numberOfRows(inSection: 0) {
                let indexPath: IndexPath = IndexPath(item: i, section: 0)
                if let cell = self.cellForRow(at: indexPath) {
                    cell.layer.transform = CATransform3DMakeScale(0.01,0.01,1)
                }
            }
        })
    }
    
}

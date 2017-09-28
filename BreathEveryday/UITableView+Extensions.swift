//
//  UITableView+Extensions.swift
//  BreathEveryday
//
//  Created by Bomi on 2017/9/28.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit

extension UITableView {
    
    func emergeOrderly(from indexRow: Int) {
        let cellCounts = self.visibleCells.count
        if indexRow < cellCounts {
            let indexPath: IndexPath = IndexPath(item: indexRow, section: 0)
            if let cell = self.cellForRow(at: indexPath) {
                cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
                UIView.animate(withDuration: 0.25, animations: {
                    cell.layer.transform = CATransform3DMakeScale(1.3,1.3,1)
                },completion: { finished in
                    UIView.animate(withDuration: 0.1, animations: {
                        cell.layer.transform = CATransform3DMakeScale(1,1,1)
                    })
                    self.emergeOrderly(from: indexRow + 1)
                })
            }
        }
    }
    
    func shrinkAllcell() {
        
        let cellCounts = self.visibleCells.count
        for cellRow in 0...cellCounts {
            let indexPath: IndexPath = IndexPath(item: cellRow, section: 0)
            if let cell = self.cellForRow(at: indexPath) {
                cell.layer.transform = CATransform3DMakeScale(0,0,1)
            }
        }
    }
    
}

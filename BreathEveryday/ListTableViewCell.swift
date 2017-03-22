//
//  ListTableViewCell.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/3/20.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var viewDetailImage: UIImageView!
    let viewDetailBtn = UIButton()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        viewDetailBtn.layer.frame = CGRect(x: 0, y: 0, width: viewDetailImage.frame.width, height: viewDetailImage.frame.height)
        viewDetailBtn.alpha = 0.1
        viewDetailImage.addSubview(viewDetailBtn)
        textView.delegate = self
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            textView?.becomeFirstResponder()
            
        } else {
            textView?.resignFirstResponder()
        }
    }
    
}

extension ListTableViewCell: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        _ = textView.text
        //you can do something here when editing is ended
        print("end editing")
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        
        if text == "\n" {
//            textView.resignFirstResponder()
//            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.textView = textView
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width,
                                                   height: 1000)) // need to fix
        
        guard let tableView = textView.superview?.superview?.superview?.superview as? UITableView else {
            return
        }
        
        // Resize the cell when size's changing
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
            print(textView.tag)
        }
        //allow to see when typing
        let indexPath = IndexPath(row: textView.tag + 1, section: 0)
        tableView.scrollToRow(at: indexPath,
                              at: .bottom,
                              animated: false)
    }
}






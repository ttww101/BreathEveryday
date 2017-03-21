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
        
        self.setupTextView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            textView?.becomeFirstResponder()
        } else {
            textView?.resignFirstResponder()
        }
    }
    
    func setupTextView() {
        textView.scrollsToTop = false;
        textView.isScrollEnabled = true;
        textView.addObserver(self, forKeyPath: "contentSize", options:[ NSKeyValueObservingOptions.old , NSKeyValueObservingOptions.new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let changeDict = change, let constraint = textViewHeightConstraint, let view = self.textView {
            if object as? NSObject == self.textView && keyPath == "contentSize" {
                if let oldContentSize = (changeDict[NSKeyValueChangeKey.oldKey] as AnyObject).cgSizeValue,
                    let newContentSize = (changeDict[NSKeyValueChangeKey.newKey] as AnyObject).cgSizeValue {
                    let dy = newContentSize.height - oldContentSize.height + 5
                    constraint.constant = constraint.constant + dy;
                    self.contentView.layoutIfNeeded()
                    let contentOffsetToShowLastLine = CGPoint(x: 0.0, y: view.contentSize.height - view.bounds.height)
                    view.contentOffset = contentOffsetToShowLastLine
                }
            }
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
        //if you hit "Enter" you resign first responder
        //and don't put this character into text view text
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.textView = textView
    }
    
    //this actually resize a text view
    func textViewDidChange(_ textView: UITextView) {
        
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width,
                                                   height: 1000)) // need to fix
        
        guard let tableView = textView.superview?.superview?.superview?.superview as? UITableView else {
            print(textView.superview?.superview?.superview?.superview)
            return }
        print("typing")
        // Resize the cell only when cell's size is changed
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
            print(textView.tag)
            let indexPath = IndexPath(row: textView.tag + 1, section: 0)
            tableView.scrollToRow(at: indexPath,
                                  at: .bottom,
                                  animated: false)
        }
    }
}






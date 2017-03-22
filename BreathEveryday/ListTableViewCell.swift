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
    @IBOutlet weak var viewDetailImage: UIImageView!
    let viewDetailBtn = UIButton()
    let coveredAddItemView = UIView()
    let emptyView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addCoveredView()
        addDetailBtn()
        addToolBarOnKeyboard()
        textView.delegate = self
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            textView?.becomeFirstResponder()
        } else {
            textView?.resignFirstResponder()
        }
        
        print(selected)
        
    }
    
    func addToolBarOnKeyboard() {
        
        let toolBar = UIToolbar()
        
        let starBtn = UIBarButtonItem(customView: createButtonWithImage(image: #imageLiteral(resourceName: "Star-48"), action: #selector(btnStarToolBar)))
        
        let locateBtn = UIBarButtonItem(customView: createButtonWithImage(image: #imageLiteral(resourceName: "Marker-50"), action: #selector(btnLocateToolBar)))
        
        let calendarBtn = UIBarButtonItem(customView: createButtonWithImage(image: #imageLiteral(resourceName: "Calendar Filled-50"), action: #selector(btnCalendarToolBar)))
        
        let alarmBtn = UIBarButtonItem(customView: createButtonWithImage(image: #imageLiteral(resourceName: "Alarm-50"), action: #selector(btnAlarmToolBar)))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(dismissKeyboard))
        
        toolBar.setItems([starBtn, locateBtn, calendarBtn, alarmBtn, flexibleSpace, doneBtn], animated: false)
        
        toolBar.sizeToFit()
        textView.inputAccessoryView = toolBar
        
    }
    
    func createButtonWithImage(image: UIImage, action: Selector) -> UIButton {
        
        let createBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 27))
        createBtn.addTarget(self, action: action, for: .touchUpInside)
        createBtn.setImage(image, for: .normal)
        createBtn.imageView?.contentMode = .scaleAspectFit
        createBtn.imageView?.translatesAutoresizingMaskIntoConstraints = false
        createBtn.imageView?.topAnchor.constraint(equalTo: createBtn.topAnchor).isActive = true
        createBtn.imageView?.bottomAnchor.constraint(equalTo: createBtn.bottomAnchor).isActive = true
        createBtn.imageView?.leadingAnchor.constraint(equalTo: createBtn.leadingAnchor).isActive = true
        createBtn.imageView?.trailingAnchor.constraint(equalTo: createBtn.trailingAnchor).isActive = true
        
        return createBtn
    }
    
    func btnStarToolBar() {
        print("star")
    }
    
    func btnLocateToolBar() {
        print("locate")
    }
    
    func btnCalendarToolBar() {
        print("calendar")
    }
    
    func btnAlarmToolBar() {
        print("alarm")
    }
    
    func dismissKeyboard() {
        contentView.endEditing(true)
    }
    
    func removeCoveredView() {
        UIView.animate(withDuration: 0.35, animations: {
            //enable text
            self.textView.becomeFirstResponder()
            //remove next emptyview
            if let tableView = self.textView.superview?.superview?.superview?.superview as? UITableView {
                if let nextCell = tableView.cellForRow(at: IndexPath(row: self.textView.tag + 1, section: 0)) as? ListTableViewCell {
                    nextCell.emptyView.removeFromSuperview()
                }
                tableView.beginUpdates()
                tableView.insertRows(at: [IndexPath(row: 10 + countForEnableCell, section: 0)], with: .fade)
                countForEnableCell += 1
                tableView.endUpdates()
            }
            //removing animation
            self.coveredAddItemView.frame = CGRect(x: self.coveredAddItemView.frame.maxX - 50, y: self.coveredAddItemView.frame.minY, width: self.coveredAddItemView.frame.width, height: self.coveredAddItemView.frame.height)
        }, completion: { (_) in
            //remove coveredAddItemView
            self.coveredAddItemView.removeFromSuperview()
        })
    }
    
    //Default set up
    func addDetailBtn() {
        viewDetailBtn.layer.frame = CGRect(x: 0, y: 0, width: viewDetailImage.frame.width, height: viewDetailImage.frame.height)
        viewDetailBtn.alpha = 0.1
        viewDetailImage.addSubview(viewDetailBtn)
    }
    
    func addCoveredView() {
        //coveredView
        contentView.addSubview(coveredAddItemView)
        coveredAddItemView.backgroundColor = contentView.backgroundColor
        coveredAddItemView.translatesAutoresizingMaskIntoConstraints = false
        coveredAddItemView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        coveredAddItemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        coveredAddItemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        coveredAddItemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        coveredAddItemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeCoveredView)))
        //plusImageView
        let plusImageView = UIImageView()
        plusImageView.contentMode = .scaleAspectFit
        plusImageView.alpha = 0.5
        plusImageView.image = #imageLiteral(resourceName: "Plus-50")
        plusImageView.backgroundColor = contentView.backgroundColor
        coveredAddItemView.addSubview(plusImageView)
        plusImageView.translatesAutoresizingMaskIntoConstraints = false
        plusImageView.topAnchor.constraint(equalTo: coveredAddItemView.topAnchor).isActive = true
        plusImageView.bottomAnchor.constraint(equalTo: coveredAddItemView.bottomAnchor).isActive = true
        plusImageView.leadingAnchor.constraint(equalTo: coveredAddItemView.leadingAnchor, constant: 10).isActive = true
        plusImageView.trailingAnchor.constraint(equalTo: coveredAddItemView.leadingAnchor, constant: 40).isActive = true
        //CoveredEmtyView
        emptyView.backgroundColor = contentView.backgroundColor
        contentView.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        emptyView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        emptyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        emptyView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
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
        }
        //allow to see when typing
        print(textView.tag)
        let indexPath = IndexPath(row: textView.tag + 1, section: 0)
        tableView.scrollToRow(at: indexPath,
                              at: .bottom,
                              animated: true)
    }
    
}






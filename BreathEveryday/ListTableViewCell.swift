//
//  ListTableViewCell.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/3/20.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit
import CoreData

enum CustomButton {
    
    case alarm
    case calender
    case locate
    case star
    
    var button: UIButton {
        
        guard let button = UINib(nibName: "KeyboardBarButton", bundle: nil).instantiate(withOwner: nil, options: nil).first as? UIButton else {
            return UIButton()
        }
        
        button.imageView?.contentMode = .scaleAspectFit
        
        switch self {
            
        case .alarm:
            
            button.setImage(#imageLiteral(resourceName: "Alarm-50"), for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 25)
            
        case .calender:
            
            button.setImage(#imageLiteral(resourceName: "Calendar-64"), for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 33)
            
        case .locate:
            
            button.setImage(#imageLiteral(resourceName: "Worldwide Location Filled-50"), for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 27)
            
        case .star:
            
            button.setImage(#imageLiteral(resourceName: "Star-48"), for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 26)
            
        }
        
        return button
        
    }
    
}


class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var viewDetailImage: UIImageView!
    var viewDetailBtn = UIButton()
    let coveredAddItemView = UIView()
    let moc = UIApplication.shared.delegate as! AppDelegate
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.delegate = self
        addCoveredView()
        addDetailBtn()
        addToolBarOnKeyboard()

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            textView?.becomeFirstResponder()
        } else {
            textView?.resignFirstResponder()
        }
        
    }
    
// Toolbar begin
//------------------------------------------
    func addToolBarOnKeyboard() {
        
        let toolBar = UIToolbar()
        
        let alarmBtn = CustomButton.alarm.button
        alarmBtn.addTarget(self, action: #selector(btnAlarmToolBar), for: .touchUpInside)
        let calendarBtn = CustomButton.calender.button
        calendarBtn.addTarget(self, action: #selector(btnCalendarToolBar), for: .touchUpInside)
        let locateBtn = CustomButton.locate.button
        locateBtn.addTarget(self, action: #selector(btnLocateToolBar), for: .touchUpInside)
        let starBtn = CustomButton.star.button
        starBtn.addTarget(self, action: #selector(btnStarToolBar), for: .touchUpInside)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(dismissKeyboard))
        
        toolBar.setItems([UIBarButtonItem(customView: starBtn),
                          UIBarButtonItem(customView: locateBtn),
                          UIBarButtonItem(customView: calendarBtn),
                          UIBarButtonItem(customView: alarmBtn),
                          flexibleSpace,
                          doneBtn]
                        , animated: false)
        toolBar.sizeToFit()
        textView.inputAccessoryView = toolBar
        
    }
    
    func createButtonWithImage(image: UIImage, scale: CGFloat, action: Selector) -> UIButton {
        
        let keyboardBtn = UINib(nibName: "KeyboardBarButton", bundle: nil).instantiate(withOwner: nil, options: nil).first
        guard let returnBtn = keyboardBtn as? KeyboardBarButton else {
            return UIButton()
        }
        returnBtn.addTarget(self, action: action, for: .touchUpInside)
        returnBtn.setImage(image, for: .normal)
        returnBtn.frame = CGRect(x: 0, y: 0, width: 60, height: scale * 26)
        
        return returnBtn
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
        
        //end edit
        contentView.endEditing(true)
        
        //update content
        updateSingleData(row: self.textView.tag, content: "")
        
    }
// Toolbar end
//------------------------------------------
    
    func addNewRowsForList() {
        
        guard let tableView = self.textView.superview?.superview?.superview?.superview as? UITableView else {
            return
        }
        countForEnableCell += 1
        let newIndexPath = IndexPath(row: countForEnableCell - 1, section: listSectionType.content.hashValue)
        
        UIView.animate(withDuration: 0.4, animations: {
            //insert a row
            tableView.beginUpdates()
            //insert
            tableView.insertRows(at: [newIndexPath], with: .none)
            tableView.endUpdates()
            //core data
            self.addSingleData(row: newIndexPath.row, content: "")
            //removing animation
//            self.contentView.frame = CGRect(x: self.contentView.frame.minX, y: self.contentView.frame.maxY, width: self.contentView.frame.width, height: 0)
        }, completion: { (_) in
            //allow new added row to see
            tableView.scrollToRow(at: newIndexPath,
                                  at: .bottom,
                                  animated: false)
            //get add cell and ready to type
            guard let addCell = tableView.cellForRow(at: IndexPath(row: countForEnableCell - 1, section: listSectionType.content.hashValue)) as? ListTableViewCell else {
                return
            }
            addCell.textView.becomeFirstResponder()
            
            
//            //remove next emptyview
//            if let nextCell = tableView.cellForRow(at: IndexPath(row: self.textView.tag + 1, section: 0)) as? ListTableViewCell {
//                nextCell.emptyView.removeFromSuperview()
//            }
//            remove coveredAddItemView
//            self.coveredAddItemView.removeFromSuperview()
        })
    }
    
}

extension ListTableViewCell: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        //saveContents
        _ = textView.text
        //you can do something here when editing is ended
        
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
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard let tableView = textView.superview?.superview?.superview?.superview as? UITableView else {
            return
        }
        
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width,
                                                   height: 1000)) // need to fix
        // Resize the cell when size's changing
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
        
    }
    
    
}

//For CoreData
//-----------------------------------
extension ListTableViewCell {
    
    func addSingleData(row: Int, content: String) {
    
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Content", in: moc.persistentContainer.viewContext) else { return }
        print(NSPersistentContainer.defaultDirectoryURL())
        let insertObject = Content(entity: entityDescription, insertInto: moc.persistentContainer.viewContext)
        insertObject.content = content
        insertObject.row = Int32(row)
        moc.saveContext()
        
    }
    
    func updateSingleData(row: Int, content: String) {
        
        let managedContext = moc.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        do {
            guard let results = try managedContext.fetch(request) as? [Content] else {
                return
            }
            results[row].content = content
            moc.saveContext()
        } catch {
            fatalError("\(error)")
        }
        
    }
    
}



//For Appearance
//------------------------------------
extension ListTableViewCell {
    
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
        coveredAddItemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addNewRowsForList)))
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
//        emptyView.backgroundColor = contentView.backgroundColor
//        contentView.addSubview(emptyView)
//        emptyView.translatesAutoresizingMaskIntoConstraints = false
//        emptyView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
//        emptyView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
//        emptyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
//        emptyView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
    }

}






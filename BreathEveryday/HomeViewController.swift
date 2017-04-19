//
//  ViewController.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/3/20.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit
import CoreData
import IGColorPicker

enum Mode {
    case normal
    case setup
}

class HomeViewController: UIViewController {
    
    let button1 = UIButton()
    @IBOutlet weak var quoteButton: UIButton!
    @IBOutlet weak var quoteView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var shopBtton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    var quoteViewBottomConstraint: NSLayoutConstraint?
    let quoteLbl = UILabel()
    var isAnimating: Bool = false
    let blackTransparentView = UIView()
    @IBOutlet weak var categorysCollectionView: UICollectionView!
    var categoryScrollViewConstraint: NSLayoutConstraint?
    var colorPickerViewConstraint: NSLayoutConstraint?
    @IBOutlet weak var categoryDoneBtn: UIButton!
    var categoryDataArr: [Category] = []
    var colorPickerView: ColorPickerView!
    var selectedCatogoryRow: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        controllerSetup()
    }
    
    func controllerSetup() {
        
        //quote
        quoteViewBottomConstraint = NSLayoutConstraint(item: quoteView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 25)
        view.addConstraint(quoteViewBottomConstraint!)
        quoteView.layer.borderColor = UIColor.gray.cgColor
        quoteView.layer.borderWidth = 3
        quoteLbl.numberOfLines = 0
        quoteLbl.adjustsFontSizeToFitWidth = true
        quoteButton.addTarget(self, action: #selector(btnQuoteBtn), for: .touchUpInside)
        quoteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissQuote)))
        
        //menu
        menuButton.alpha = 0.75
        shopBtton.alpha = 0.75
        settingButton.alpha = 0.75
        var image = #imageLiteral(resourceName: "Thumbnails-48").withRenderingMode(.alwaysTemplate)
        menuButton.setImage(image, for: .normal)
        menuButton.tintColor = .black
        menuButton.imageView?.contentMode = .scaleAspectFit
        image = #imageLiteral(resourceName: "Settings-50").withRenderingMode(.alwaysTemplate)
        settingButton.setImage(image, for: .normal)
        settingButton.tintColor = .black
        settingButton.imageView?.contentMode = .scaleAspectFit
        menuButton.addTarget(self, action: #selector(btnMenuBtn), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(btnSettingBtn), for: .touchUpInside)
        shopBtton.addTarget(self, action: #selector(btnShopBtn), for: .touchUpInside)
        
        //category
        image = #imageLiteral(resourceName: "Checkmark Filled-50").withRenderingMode(.alwaysTemplate)
        categoryDoneBtn.setImage(image, for: .normal)
        categoryDoneBtn.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 0, 15)
        categoryDoneBtn.imageView?.contentMode = .scaleAspectFit
        categoryDoneBtn.addTarget(self, action: #selector(btnDone), for: .touchUpInside)
        categorysCollectionView.allowsMultipleSelection = true
        
        categorysCollectionView.delegate = self
        categorysCollectionView.dataSource = self
        categorysCollectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        categoryScrollViewConstraint = NSLayoutConstraint(item: categorysCollectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(categoryScrollViewConstraint!)
        
        //color picker
        colorPickerView = ColorPickerView()
        colorPickerView.delegate = self
        colorPickerView.layoutDelegate = self
        colorPickerView.backgroundColor = colorDarkPurple
        colorPickerView.selectionStyle = .check
        view.addSubview(colorPickerView)
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        colorPickerView.topAnchor.constraint(equalTo: categorysCollectionView.topAnchor, constant: 300).isActive = true
        colorPickerView.bottomAnchor.constraint(equalTo: categorysCollectionView.topAnchor, constant: 0).isActive = true
        colorPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        colorPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        colorPickerViewConstraint = NSLayoutConstraint(item: colorPickerView, attribute: .top, relatedBy: .equal, toItem: categorysCollectionView, attribute: .top, multiplier: 1, constant: 0)
        view.addConstraint(colorPickerViewConstraint!)
        
        
        //bubbles
        var frame = CGRect()
        
        for i in 0...categoryStringArray.count - 1 {
            
            var isCreated = false
            var createButton = UIButton()
            let name = categoryStringArray[i]
            let image = categoryImageArray[i].withRenderingMode(.alwaysTemplate)
            var color = UIColor.lightGray
            //MARK: find existing data
            
            if let category = CategoryManager.shared.read(name: name) {
                //TODO: read saved color
                //transfer data needed
                isCreated = category.isCreated
                if let colorData = category.color as Data? {
                    color = UIColor.color(withData: colorData)
                }
                frame = CGRect(x: CGFloat(category.posX),
                               y: CGFloat(category.posY),
                               width: CGFloat(category.width),
                               height: CGFloat(category.height))
                createButton = createRandomBubble(with: image,
                                                  in: frame,
                                                  color: color)
                createButton.tag = i // to display name
                createButton.addTarget(self, action: #selector(displayListView), for: .touchUpInside)
                view.addSubview(createButton)
            }
            
            let category = Category.init(name: name,
                                         image: image,
                                         button: createButton,
                                         isCreated: isCreated,
                                         frame: frame,
                                         color: color)
            categoryDataArr.append(category)
            
        }
        
        //handle set up mode
        var willShowSetupMode = true
        for category in categoryDataArr {
            if category.isCreated == true {
                willShowSetupMode = false
                break
            }
        }
        if willShowSetupMode {
            showupFirstTime()
        }
        
    }
    
    func showupFirstTime() {
        //add black view to view
        blackTransparentView.alpha = 0.8
        blackTransparentView.backgroundColor = .black
        view.addSubview(blackTransparentView)
        blackTransparentView.translatesAutoresizingMaskIntoConstraints = false
        blackTransparentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        blackTransparentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        blackTransparentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        blackTransparentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            
        })
        //send views to front
        view.bringSubview(toFront: categorysCollectionView)
        view.bringSubview(toFront: colorPickerView)
        view.bringSubview(toFront: categoryDoneBtn)
        
        //button action & appearance change
        swichMode(to: .setup)
        
        categoryScrollViewConstraint?.constant = -100
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            
        })

    }
    
    func createRandomBubble(with image: UIImage, in frame: CGRect?, color: UIColor) -> UIButton {
        
        //button1
        let button = UIButton()
        if let frame = frame {
            button.layer.frame = frame
        } else {
            let xPos = arc4random_uniform(UInt32(view.frame.width) - 100)
            let yPos = arc4random_uniform(UInt32(colorPickerView.frame.minY) - 100 - UInt32(quoteButton.frame.maxY)) + UInt32(quoteButton.frame.maxY)
            button.layer.frame = CGRect(x: Int(xPos), y: Int(yPos), width: 80, height: 80)
        }
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 40
        button.backgroundColor = color
        button.layer.opacity = 0.65
        
        //image1
        let imageRendered = image.withRenderingMode(.alwaysTemplate)
        button.tintColor = UIColor.white
        button.setImage(imageRendered, for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
        return button
    }
    
    func btnMenuBtn() {
        
        if !menuButton.isSelected {
            menuButton.isEnabled = false
            shopBtton.isEnabled = false
            settingButton.isEnabled = false
            menuButton.isSelected = true
            let settingBtnFrame = settingButton.frame
            let shopBtnFrame = shopBtton.frame
            settingButton.frame = CGRect(x: menuButton.frame.minX, y: menuButton.frame.minY, width: 0, height: 0)
            shopBtton.frame = CGRect(x: menuButton.frame.minX, y: menuButton.frame.minY, width: 0, height: 0)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.settingButton.isHidden = false
                self.shopBtton.isHidden = false
                self.settingButton.frame = settingBtnFrame
                self.shopBtton.frame = shopBtnFrame
            }, completion: { (_) in
                self.menuButton.isEnabled = true
                self.settingButton.isEnabled = true
                self.shopBtton.isEnabled = true
            })
        } else {
            shrinkMenu()
        }
        
    }
    
    func shrinkMenu() {
        
        menuButton.isEnabled = false
        settingButton.isEnabled = false
        shopBtton.isEnabled = false
        let settingBtnFrame = settingButton.frame
        let shopBtnFrame = shopBtton.frame
        UIView.animate(withDuration: 0.25, animations: {
            self.settingButton.frame = CGRect(x: self.menuButton.frame.midX, y: self.menuButton.frame.midY, width: 0, height: 0)
            self.shopBtton.frame = CGRect(x: self.menuButton.frame.midX, y: self.menuButton.frame.midY, width: 0, height: 0)
        }, completion: { (_) in
            self.settingButton.frame = settingBtnFrame
            self.shopBtton.frame = shopBtnFrame
            self.menuButton.isSelected = false
            self.settingButton.isHidden = true
            self.shopBtton.isHidden = true
            self.menuButton.isEnabled = true
        })
        
    }
    
    func btnSettingBtn() {
        
        self.menuButton.isSelected = false
        self.settingButton.isHidden = true
        self.shopBtton.isHidden = true
        
        //add black view to view
        blackTransparentView.alpha = 0.8
        blackTransparentView.backgroundColor = .black
        view.addSubview(blackTransparentView)
        blackTransparentView.translatesAutoresizingMaskIntoConstraints = false
        blackTransparentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        blackTransparentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        blackTransparentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        blackTransparentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        
        //send views to front
        view.bringSubview(toFront: button1)
        view.bringSubview(toFront: quoteButton)
        view.bringSubview(toFront: categorysCollectionView)
        view.bringSubview(toFront: colorPickerView)
        view.bringSubview(toFront: categoryDoneBtn)
        for category in categoryDataArr {
            if category.isCreated {
                view.bringSubview(toFront: category.button)
            }
        }
        
        //button action & appearance change
        swichMode(to: .setup)
        
    }
    
    func swichMode(to mode: Mode) {
        
        switch mode {
            
        case .normal:
            //button targets
            for category in categoryDataArr {
                category.button.removeTarget(self, action: #selector(displayCategoryScrollView), for: .touchUpInside)
                category.button.addTarget(self, action: #selector(displayListView), for: .touchUpInside)
            }
            button1.removeTarget(self, action: #selector(displayCategoryScrollView), for: .touchUpInside)
            button1.addTarget(self, action: #selector(displayListView), for: .touchUpInside)
            
            let image = #imageLiteral(resourceName: "Message-50").withRenderingMode(.alwaysTemplate)
            quoteButton.setImage(image, for: .normal)
            quoteButton.tintColor = .black
            quoteButton.removeTarget(self, action: #selector(btnQuoteBtnSettingMode), for: .touchUpInside)
            quoteButton.addTarget(self, action: #selector(btnQuoteBtn), for: .touchUpInside)
            
        case .setup:
            //button targets
            for category in categoryDataArr {
                category.button.removeTarget(self, action: #selector(displayListView), for: .touchUpInside)
                category.button.addTarget(self, action: #selector(displayCategoryScrollView), for: .touchUpInside)
            }
            button1.removeTarget(self, action: #selector(displayListView), for: .touchUpInside)
            button1.addTarget(self, action: #selector(displayCategoryScrollView), for: .touchUpInside)
            
            let image = #imageLiteral(resourceName: "Message-50").withRenderingMode(.alwaysTemplate)
            quoteButton.setImage(image, for: .normal)
            quoteButton.tintColor = .white
            quoteButton.removeTarget(self, action: #selector(btnQuoteBtn), for: .touchUpInside)
            quoteButton.addTarget(self, action: #selector(btnQuoteBtnSettingMode), for: .touchUpInside)
            
        }
    }
    
    func displayCategoryScrollView(sender: UIButton) {
        
        let image = #imageLiteral(resourceName: "Message-50").withRenderingMode(.alwaysTemplate)
        quoteButton.setImage(image, for: .normal)
        quoteButton.tintColor = .black
        quoteButton.removeTarget(self, action: #selector(btnQuoteBtnSettingMode), for: .touchUpInside)
        categoryScrollViewConstraint?.constant = -100
        colorPickerViewConstraint?.constant = -50
        selectedCatogoryRow = sender.tag
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            
            //change color
            let clickedIndexPath = IndexPath(row: sender.tag, section: 0)
            //selected color
//            if let cell = self.categorysCollectionView.cellForItem(at: clickedIndexPath) as? CategoryCollectionViewCell {
//                cell.colorBK = sender.backgroundColor!
//            }
            //selec created items
            for category in self.categoryDataArr {
                if category.isCreated {
                    self.categorysCollectionView.selectItem(
                        at: IndexPath(row: category.button.tag, section: 0),
                        animated: false,
                        scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
                }
            }
            
            self.categorysCollectionView.scrollToItem(at: clickedIndexPath, at: .centeredHorizontally, animated: true)
            
        })
    }
    
    func btnQuoteBtnSettingMode() {
        btnDone()
    }
    
    func btnDone() {
        //calculate count
        var count = 0
        for category in categoryDataArr {
            if category.isCreated {
                count += 1
            }
        }
        //check if more than one selected
        if count > 0 {
            blackTransparentView.removeFromSuperview()
            swichMode(to: .normal)
            categoryScrollViewConstraint?.constant = 0
            colorPickerViewConstraint?.constant = 0
            
            //MARK: Core data save
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let moc = appDelegate.persistentContainer.viewContext
            
            do {
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CategoryMO")
                
                guard let results = try moc.fetch(request) as? [CategoryMO] else {
                    return
                }
                
                for result in results {
                    
                    moc.delete(result)
                    
                }
                
                try moc.save()
                
            } catch {}
            
            for category in categoryDataArr {
                if category.isCreated {
                    
                    guard let entityDescription = NSEntityDescription.entity(forEntityName: "CategoryMO", in: moc) else {
                        
                        return
                        
                    }
                    
                    let cMO = CategoryMO(entity: entityDescription, insertInto: moc)
                    
                    cMO.name = category.name
                    
                    cMO.isCreated = category.isCreated
                    
                    let frame = category.frame
                    cMO.posX = Float(frame.minX)
                    cMO.posY = Float(frame.minY)
                    cMO.width = Float(frame.width)
                    cMO.height = Float(frame.height)
                    cMO.color = category.color.encode() as NSData
                }
            }
            
            do {
                
                try moc.save()
                
            } catch { print(error.localizedDescription) }
            
            
        } else {
            //TODO: alert nothing selected
        }
    }
    
    func btnShopBtn() {
        
    }
    
    func btnQuoteBtn(sender: UIButton) {
        
        if !sender.isSelected {
            
            view.bringSubview(toFront: quoteView)
            //change state
            sender.isSelected = true
            sender.isEnabled = false
            //quote label
            quoteLbl.text = quotes[numberOfQuote]
            if numberOfQuote < quotes.count - 1 { numberOfQuote += 1 } else { numberOfQuote = 0 }
            let maxSize = CGSize(width: quoteView.frame.width - 10, height: view.frame.maxY)
            let size = quoteLbl.sizeThatFits(maxSize)
            quoteLbl.frame = CGRect(origin: CGPoint(x: 5, y: 5), size: size)
            quoteViewBottomConstraint?.constant = quoteLbl.frame.height + 10
            view.layoutIfNeeded()
            quoteView.addSubview(quoteLbl)
            //animation
            let animateView = UIView()
            animateView.backgroundColor = quoteView.backgroundColor
            animateView.layer.frame = CGRect(x: quoteView.frame.minX, y: quoteView.frame.minY, width: 0, height: 0)
            animateView.layer.borderColor = quoteView.layer.borderColor
            animateView.layer.borderWidth = quoteView.layer.borderWidth
            animateView.alpha = quoteView.alpha
            view.addSubview(animateView)
            
            UIView.animate(withDuration: 0.3, animations: {
                animateView.layer.frame = self.quoteView.frame
            }, completion: { (_) in
                self.quoteView.isHidden = false
                animateView.removeFromSuperview()
                sender.isEnabled = true
            })

        } else {
            dismissQuote()
        }
        
    }
    
    func dismissQuote() {
        //state
        quoteView.isHidden = true
        quoteButton.isEnabled = false
        //animation
        let animateView = UIView()
        animateView.backgroundColor = quoteView.backgroundColor
        animateView.layer.frame = CGRect(x: quoteView.frame.minX, y: quoteView.frame.minY, width: quoteView.frame.width, height: quoteView.frame.height)
        animateView.layer.borderColor = quoteView.layer.borderColor
        animateView.layer.borderWidth = quoteView.layer.borderWidth
        animateView.alpha = 1
        view.addSubview(animateView)
        UIView.animate(withDuration: 0.2, animations: {
            animateView.layer.frame = CGRect(x: self.quoteView.frame.minX, y: self.quoteView.frame.minY, width: 0, height: 0)
        }, completion: { (_) in
            self.quoteLbl.removeFromSuperview()
            animateView.removeFromSuperview()
            self.quoteButton.isEnabled = true
            self.quoteButton.isSelected = false
        })
    }
    
    func displayListView(sender: UIButton) {
        
        if let navigationVC = storyboard?.instantiateViewController(withIdentifier: "HomeNavigationController") as? UINavigationController {
            
            //send value
            guard let vc = navigationVC.childViewControllers[0] as? ListViewController else { return }
            vc.listTitle = categoryDataArr[sender.tag].name
            vc.bubbleSyncColor = categoryDataArr[sender.tag].color
            
            //animation
            let subView = UIView()
            subView.layer.frame = navigationVC.view.frame
            subView.backgroundColor = UIColor.white
            navigationVC.view.addSubview(subView)
            subView.layer.opacity = 1
            
            self.present(navigationVC, animated: false, completion: {
                UIView.animate(withDuration: 0.5, animations: {
                    subView.layer.opacity = 0.0
                }, completion: { (_) in
                    subView.removeFromSuperview()
                })
            })
        }

    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else { return }
        
        cell.isCreated = true
        let createColor = UIColor().randomColor()
        categoryDataArr[indexPath.row].isCreated = true
        let createBtn = createRandomBubble(with: categoryImageArray[indexPath.row],
                                           in: nil,
                                           color: createColor)
        createBtn.addTarget(self, action: #selector(displayCategoryScrollView), for: .touchUpInside)
        createBtn.tag = indexPath.row
        selectedCatogoryRow = indexPath.row
        categoryDataArr[indexPath.row].button = createBtn
        categoryDataArr[indexPath.row].frame = createBtn.frame
        categoryDataArr[indexPath.row].color = createColor
        view.addSubview(createBtn)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else { return }
        
        let getCategory = categoryDataArr[indexPath.row]
        getCategory.button.removeFromSuperview()
        cell.isCreated = false
        categoryDataArr[indexPath.row].isCreated = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return categoryDataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = categorysCollectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
//        cell.colorBK = categoryDataArr[indexPath.row].color
        cell.configureCell()
        cell.label.text = categoryDataArr[indexPath.row].name
        let image = categoryDataArr[indexPath.row].image
        cell.imageView.image = image
        cell.isCreated = categoryDataArr[indexPath.row].isCreated
        
        return cell
    }
    
}

extension HomeViewController: ColorPickerViewDelegate {
    
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        
        // A color has been selected
        //category selected
//        let catIndexPath = IndexPath(row: selectedCatogoryRow, section: 0)
//        categorysCollectionView.cellForItem(at: catIndexPath)?.contentView.backgroundColor = colorPickerView.colors[indexPath.row]
        //bubble selected
        categoryDataArr[selectedCatogoryRow].button.backgroundColor = colorPickerView.colors[indexPath.row]
        
        //TODO: save color
        categoryDataArr[selectedCatogoryRow].color = colorPickerView.colors[indexPath.row]
        
    }
    
    // This is an optional method
    func colorPickerView(_ colorPickerView: ColorPickerView, didDeselectItemAt indexPath: IndexPath) {
        // A color has been deselected
        
    }
    
}

extension HomeViewController: ColorPickerViewDelegateFlowLayout {
    
    // ------------------------------------------------------------------
    // All these methods are optionals, your are not to implement them 🖖🏻
    // ------------------------------------------------------------------
    
    func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // The size for each cell
        // 👉🏻 WIDTH AND HEIGHT MUST BE EQUALS!
        return CGSize(width: 30, height: 30)
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // Space between cells
        return 10
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        // Space between rows
        return 10
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, insetForSectionAt section: Int) -> UIEdgeInsets {
        // Inset used aroud the view
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}




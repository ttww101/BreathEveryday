//
//  ViewController.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/3/20.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit
import CoreData
import Spring
import DynamicColor
import Crashlytics


class HomeViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var quoteButton: SpringButton!
    @IBOutlet weak var weatherImageView: SpringImageView!
    @IBOutlet weak var quoteView: QuoteView!
    @IBOutlet weak var menuButton: SpringButton!
    @IBOutlet weak var infoBtton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    var quoteViewBottomConstraint: NSLayoutConstraint?
    let quoteLbl = QuoteLabel()
    var isAnimating: Bool = false
    let blackTransparentView = SpringView()
    @IBOutlet weak var categorysCollectionView: UICollectionView!
    var categoryScrollViewConstraint: NSLayoutConstraint?
    var colorPickerViewConstraint: NSLayoutConstraint?
    @IBOutlet weak var categoryDoneBtn: CategoryDoneButton!
    var categoryDataArr: [Category] = []
    let colorPickerView = IGColorPickerView()
    var selectedCatogoryRow: Int = 0
    var circleCenter: CGPoint! // record for bubble circle center
    var currentMode: Mode = .normal //record for distinguish drag out of view action
    var dragAnimatorArray: [UIViewPropertyAnimator] = []
    @IBOutlet weak var deleteSuccessLabel: SpringLabel!
    var deleteLabelConstraint: NSLayoutConstraint?
    let tutorialScrollView = UIScrollView()
    var gestureQuitTutorial: UITapGestureRecognizer?
    var gestureSetupBackground: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controllerSetup()
    }
    
    func controllerSetup() {
        
        weatherImageView.animation = "morph"
        weatherImageView.animate()
        weatherImageView.animateNext {
            self.quoteButton.animation = "flash"
            self.quoteButton.animate()
            self.weatherImageView.animation = "morph"
            self.weatherImageView.animate()
        }
        
        //quoteBtn
        quoteButton.normalSetup(normalImage: #imageLiteral(resourceName: "Message-50"), selectedImage: #imageLiteral(resourceName: "Feedback-50"), tintColor: .white)
        quoteButton.addTarget(self, action: #selector(btnQuoteBtn), for: .touchUpInside)
        
        //quoteView
        quoteViewBottomConstraint = NSLayoutConstraint(item: quoteView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 25)
        view.addConstraint(quoteViewBottomConstraint!)
        quoteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissQuote)))
        
        //menu
        menuButton.normalSetup(normalImage: #imageLiteral(resourceName: "Thumbnails-48"),
                         selectedImage: nil,
                         tintColor: UIColor.blueMiddleGrayLight())
        settingButton.normalSetup(normalImage: #imageLiteral(resourceName: "Settings"),
                            selectedImage: nil,
                            tintColor: .white)
        infoBtton.normalSetup(normalImage: #imageLiteral(resourceName: "Help-96"),
                        selectedImage: nil,
                        tintColor: .white)
        menuButton.addTarget(self, action: #selector(btnMenuBtn), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(btnSettingBtn), for: .touchUpInside)
        infoBtton.addTarget(self, action: #selector(btnInfoBtn), for: .touchUpInside)
        
        //category
        categoryDoneBtn.addTarget(self, action: #selector(btnDone), for: .touchUpInside)
        
        //category 
        categorysCollectionView.allowsMultipleSelection = true
        categorysCollectionView.delegate = self
        categorysCollectionView.dataSource = self
        categorysCollectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        categoryScrollViewConstraint = NSLayoutConstraint(item: categorysCollectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(categoryScrollViewConstraint!)
        
        //color picker
        colorPickerView.delegate = self
        colorPickerView.layoutDelegate = self
        
        view.addSubview(colorPickerView)
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        colorPickerView.topAnchor.constraint(equalTo: categorysCollectionView.topAnchor, constant: 300).isActive = true
        colorPickerView.bottomAnchor.constraint(equalTo: categorysCollectionView.topAnchor, constant: 0).isActive = true
        colorPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        colorPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        colorPickerViewConstraint = NSLayoutConstraint(item: colorPickerView, attribute: .top, relatedBy: .equal, toItem: categorysCollectionView, attribute: .top, multiplier: 1, constant: 0)
        view.addConstraint(colorPickerViewConstraint!)
        
        //Bubbles
        var frame = CGRect()
        for i in 0...categoryStringArray.count - 1 {
            
            var isCreated = false
            var createButton = UIButton()
            let name = categoryStringArray[i]
            let image = categoryImageArray[i].withRenderingMode(.alwaysTemplate)
            var color = UIColor.lightGray
            
            if let category = CategoryManager.shared.read(name: name) {
                
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
        
        //deleteLabel
        deleteSuccessLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteSuccessLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        deleteSuccessLabel.bottomAnchor.constraint(equalTo: colorPickerView.topAnchor, constant: 0).isActive = true
        deleteSuccessLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        deleteSuccessLabel.layer.borderWidth = 1.5
        deleteSuccessLabel.layer.borderColor = UIColor.red.cgColor
        deleteLabelConstraint = NSLayoutConstraint(item: deleteSuccessLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        view.addConstraint(deleteLabelConstraint!)
        
        //show up firsttime
        var willShowFirstSetup = true
        for category in categoryDataArr {
            if category.isCreated == true {
                willShowFirstSetup = false
                break
            }
        }
        if willShowFirstSetup {
            showupFirstTime()
        }
        
        //read data to set background image
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let moc = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserMO")
        do {
            guard let results = try moc.fetch(request) as? [UserMO] else {
                return
            }
            if results.count > 0 {
                let user = results[0]
                if let image = user.backgroundImage {
                    backgroundImageView.image = UIImage(data: image as Data)
                }
            } else {
                createBackgroundDataFirstTime()
            }
        } catch {
            
            fatalError("Core Data Update: \(error)")
        }

    }
    
    func showupFirstTime() {
        
        addBlackTransparentView()
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            
            //bring views to front
            self.view.bringSubview(toFront: self.categorysCollectionView)
            self.view.bringSubview(toFront: self.colorPickerView)
            self.view.bringSubview(toFront: self.categoryDoneBtn)
            self.view.bringSubview(toFront: self.deleteSuccessLabel)
            
            //button action & appearance change
            self.switchMode(to: .setup)
            self.switchMode(to: .setupCategory)
            self.categoryScrollViewConstraint?.constant = -100
            self.colorPickerViewConstraint?.constant = -44
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
                self.alertLabel(replaceString: "Please choose categories", isHidden: false, color: .red)
            }, completion: { (completed) in
                
                UIImageWriteToSavedPhotosAlbum(#imageLiteral(resourceName: "BK-galaxy"), self, nil, nil)
                UIImageWriteToSavedPhotosAlbum(#imageLiteral(resourceName: "BK-Sword of Orion"), self, nil, nil)
                UIImageWriteToSavedPhotosAlbum(#imageLiteral(resourceName: "BK-tree"), self, nil, nil)
                UIImageWriteToSavedPhotosAlbum(#imageLiteral(resourceName: "BK-forest1"), self, nil, nil)
                UIImageWriteToSavedPhotosAlbum(#imageLiteral(resourceName: "BK-luka"), self, nil, nil)
                UIImageWriteToSavedPhotosAlbum(#imageLiteral(resourceName: "BK-beach sunset"), self, nil, nil)
                UIImageWriteToSavedPhotosAlbum(#imageLiteral(resourceName: "BK-beach sunrise"), self, nil, nil)
            })
        })
        
        //create data for the first time
        createBackgroundDataFirstTime()
    }
    
    func bubbleNestShowUpAnimation(sender: [SpringButton], toCount: Int) {

        //TODO: disable button
        sender[sender.count - toCount].animation = "fadeInUp"
        sender[sender.count - toCount].curve = "easeInOut"
        sender[sender.count - toCount].duration = 4
        sender[sender.count - toCount].damping = 10
        sender[sender.count - toCount].velocity = 0.08
        sender[sender.count - toCount].layer.opacity = 0.6
        sender[sender.count - toCount].animate()
        sender[sender.count - toCount].animate()
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (_) in
            if toCount - 1 > 0 {
                
                self.bubbleNestShowUpAnimation(sender: sender,
                                                   toCount: toCount - 1)
                
            } else {
                
            }
        }
    }
    
    func createBackgroundDataFirstTime() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let moc = appDelegate.persistentContainer.viewContext
        if let entityDescription = NSEntityDescription.entity(forEntityName: "UserMO", in: moc) {
            let user = UserMO(entity: entityDescription, insertInto: moc)
            if let imageData = UIImageJPEGRepresentation(#imageLiteral(resourceName: "BK-beach sunrise"), 1) {
                user.backgroundImage = imageData as NSData
            }
            appDelegate.saveContext()
        }
    }
    
    func btnMenuBtn() {
        
        if !menuButton.isSelected {
            menuButton.rotate = 720
            menuButton.animation = "linear"
            menuButton.force = 0
            menuButton.duration = 1
            menuButton.animate()
            menuButton.isEnabled = false
            infoBtton.isEnabled = false
            settingButton.isEnabled = false
            menuButton.isSelected = true
            let settingBtnFrame = settingButton.frame
            let shopBtnFrame = infoBtton.frame
            settingButton.frame = CGRect(x: menuButton.frame.minX, y: menuButton.frame.minY, width: 0, height: 0)
            infoBtton.frame = CGRect(x: menuButton.frame.minX, y: menuButton.frame.minY, width: 0, height: 0)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.settingButton.isHidden = false
                self.infoBtton.isHidden = false
                self.settingButton.frame = settingBtnFrame
                self.infoBtton.frame = shopBtnFrame
            }, completion: { (_) in
                self.menuButton.isEnabled = true
                self.settingButton.isEnabled = true
                self.infoBtton.isEnabled = true
            })
        } else {
            shrinkMenu()
        }
        
    }
    
    func shrinkMenu() {
        
        menuButton.rotate = -720
        menuButton.animation = "linear"
        menuButton.force = 0
        menuButton.duration = 1
        menuButton.animate()
        menuButton.isEnabled = false
        settingButton.isEnabled = false
        infoBtton.isEnabled = false
        let settingBtnFrame = settingButton.frame
        let shopBtnFrame = infoBtton.frame
        UIView.animate(withDuration: 0.25, animations: {
            self.settingButton.frame = CGRect(x: self.menuButton.frame.midX, y: self.menuButton.frame.midY, width: 0, height: 0)
            self.infoBtton.frame = CGRect(x: self.menuButton.frame.midX, y: self.menuButton.frame.midY, width: 0, height: 0)
        }, completion: { (_) in
            self.settingButton.frame = settingBtnFrame
            self.infoBtton.frame = shopBtnFrame
            self.menuButton.isSelected = false
            self.settingButton.isHidden = true
            self.infoBtton.isHidden = true
            self.menuButton.isEnabled = true
        })
        
    }
    
    func btnSettingBtn() {
        
        self.menuButton.isSelected = false
        self.settingButton.isHidden = true
        self.infoBtton.isHidden = true
        
        //add black view to view
        addBlackTransparentView()
        
        //bring views to front
        view.bringSubview(toFront: quoteButton)
        view.bringSubview(toFront: deleteSuccessLabel)
        for category in categoryDataArr {
            if category.isCreated {
                view.bringSubview(toFront: category.button)
            }
        }
        
        switchMode(to: .setup)
        alertLabel(replaceString: "Please select an item", isHidden: false, color: UIColor.blueMiddleGray())
    }
    
    func switchMode(to mode: Mode) {
        
        switch mode {
            
        case .normal:
            
            //button
            currentMode = .normal
            for category in categoryDataArr {
                category.button.removeTarget(self, action: #selector(setBubbleCategory), for: .touchUpInside)
                category.button.addTarget(self, action: #selector(displayListView), for: .touchUpInside)
            }
            
            //quote
            let image = #imageLiteral(resourceName: "Message-50").withRenderingMode(.alwaysTemplate)
            quoteButton.setImage(image, for: .normal)
            quoteButton.tintColor = .white
            quoteButton.removeTarget(self, action: #selector(btnQuoteBtnSettingMode), for: .touchUpInside)
            quoteButton.addTarget(self, action: #selector(btnQuoteBtn), for: .touchUpInside)
            
            //constrait
            categoryScrollViewConstraint?.constant = 0
            colorPickerViewConstraint?.constant = 0
            deleteLabelConstraint?.constant = 0
            
        case .tutorial:
            deleteSuccessLabel.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(quitTutorial))
            gestureQuitTutorial = gesture
            deleteSuccessLabel.addGestureRecognizer(gestureQuitTutorial!)
            removeSetupBackgroundGesture()
        
        case .setup:
            
            //bubble
            currentMode = .setup
            for category in categoryDataArr {
                category.button.removeTarget(self, action: #selector(displayListView), for: .touchUpInside)
                category.button.addTarget(self, action: #selector(setBubbleCategory), for: .touchUpInside)
            }
            
            //quote
            let image = #imageLiteral(resourceName: "Message-50").withRenderingMode(.alwaysTemplate)
            quoteButton.setImage(image, for: .normal)
            quoteButton.tintColor = .white
            quoteButton.removeTarget(self, action: #selector(btnQuoteBtn), for: .touchUpInside)
            quoteButton.addTarget(self, action: #selector(btnQuoteBtnSettingMode), for: .touchUpInside)
            
            //background
            let gesture = UITapGestureRecognizer(target: self, action: #selector(setBackground))
            gestureSetupBackground = gesture
            blackTransparentView.addGestureRecognizer(gestureSetupBackground!)
            
        case .setupCategory:
            currentMode = .setupCategory
            removeSetupBackgroundGesture()
            
        case .setupBackground:
            currentMode = .setupBackground
            removeSetupBackgroundGesture()
        }
        
    }
    
    func removeSetupBackgroundGesture() {
        if let gesture = gestureSetupBackground {
            blackTransparentView.removeGestureRecognizer(gesture)
        }
    }
    
    func setBubbleCategory(sender: UIButton) {
        
        switchMode(to: .setupCategory)
        self.deleteLabelConstraint?.constant = 0
        view.bringSubview(toFront: blackTransparentView)
        view.bringSubview(toFront: categorysCollectionView)
        view.bringSubview(toFront: colorPickerView)
        view.bringSubview(toFront: categoryDoneBtn)
        view.bringSubview(toFront: deleteSuccessLabel)
        for category in categoryDataArr {
            view.bringSubview(toFront: category.button)
        }
        quoteButton.removeTarget(self, action: #selector(btnQuoteBtnSettingMode), for: .touchUpInside)
        categoryScrollViewConstraint?.constant = -100
        colorPickerViewConstraint?.constant = -44
        selectedCatogoryRow = sender.tag
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            
            //change color
            let clickedIndexPath = IndexPath(row: sender.tag, section: 0)
            
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
            switchMode(to: .normal)
            
            //update categoryDataArray
            
            updateCategoryDataArrayFrame()
            
            //MARK: Core data save
            
            removeAllAndSaveCoreData()
            
        } else {
            alertLabel(replaceString: "please choose a category", isHidden: true, color: .red)
        }
    }
    
    func alertLabel(replaceString: String, isHidden: Bool, color: UIColor) {
        deleteSuccessLabel.text = replaceString
        deleteSuccessLabel.textColor = color
        deleteSuccessLabel.layer.borderColor = color.cgColor
        let maxSize = CGSize(width: quoteView.frame.width - 10, height: view.frame.maxY)
        let size = deleteSuccessLabel.sizeThatFits(maxSize)
        deleteLabelConstraint?.constant = size.width + 50
        view.layoutIfNeeded()
        deleteSuccessLabel.isHidden = false
        deleteSuccessLabel.animation = "fadeIn"
        deleteSuccessLabel.animateNext {
            self.deleteSuccessLabel.isHidden = isHidden
        }
    }
    
    func updateCategoryDataArrayFrame() {
        
        var count = 0
        for category in categoryDataArr {
            if category.isCreated {
                categoryDataArr[count].frame = category.button.frame
            }
            count += 1
        }
        
    }
    
    func removeAllAndSaveCoreData() {
        
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
                
                guard let entityDescription = NSEntityDescription.entity(forEntityName: "CategoryMO", in: moc) else { return }
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
        
    }
    
    func btnInfoBtn() {
        
        self.menuButton.isSelected = false
        self.settingButton.isHidden = true
        self.infoBtton.isHidden = true
        
        addBlackTransparentView()
        
        //bring views to front
        view.bringSubview(toFront: deleteSuccessLabel)
        
        //add tutorial info
        view.addSubview(tutorialScrollView)
        tutorialScrollView.isScrollEnabled = true
        tutorialScrollView.isPagingEnabled = true
        tutorialScrollView.showsHorizontalScrollIndicator = false
        tutorialScrollView.isUserInteractionEnabled = true
        tutorialScrollView.translatesAutoresizingMaskIntoConstraints = false
        tutorialScrollView.topAnchor.constraint(equalTo: blackTransparentView.centerYAnchor, constant: -200).isActive = true
        tutorialScrollView.bottomAnchor.constraint(equalTo: blackTransparentView.centerYAnchor, constant: 200).isActive = true
        tutorialScrollView.leadingAnchor.constraint(equalTo: blackTransparentView.leadingAnchor, constant: 0).isActive = true
        tutorialScrollView.trailingAnchor.constraint(equalTo: blackTransparentView.trailingAnchor, constant: 0).isActive = true
        view.layoutIfNeeded()
        
        let imageArray = [#imageLiteral(resourceName: "Help-settings"), #imageLiteral(resourceName: "Help-choose categories"), #imageLiteral(resourceName: "Help-slide to delete"), #imageLiteral(resourceName: "Help-quote display"), #imageLiteral(resourceName: "Help-event filled star"), #imageLiteral(resourceName: "Help-add note"), #imageLiteral(resourceName: "Help-tutorial")]
        
        for i in 0...imageArray.count - 1 {
            
            let imageView = UIImageView()
            imageView.image = imageArray[i]
            imageView.contentMode = .scaleAspectFit
            let xPos = self.view.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPos, y: 0, width: tutorialScrollView.frame.width, height: tutorialScrollView.frame.height)
            tutorialScrollView.contentSize.width = tutorialScrollView.frame.width * CGFloat(i + 1)
            tutorialScrollView.addSubview(imageView)
            
        }
        
        switchMode(to: .tutorial)
        alertLabel(replaceString: "Quit Tutorial", isHidden: false, color: UIColor.blueMiddleGray().lighter())
    }
    
    func addBlackTransparentView() {
        
        //add black view to view
        blackTransparentView.backgroundColor = .black
        view.addSubview(blackTransparentView)
        blackTransparentView.translatesAutoresizingMaskIntoConstraints = false
        blackTransparentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        blackTransparentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        blackTransparentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        blackTransparentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        blackTransparentView.animation = "fadeIn"
        blackTransparentView.duration = 1
        blackTransparentView.animate()
        blackTransparentView.alpha = 0.6
    }
    
    func quitTutorial() {
        tutorialScrollView.removeFromSuperview()
        btnDone()
        deleteSuccessLabel.removeGestureRecognizer(gestureQuitTutorial!)
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
            
            //save frame
            for category in categoryDataArr {
                category.button.layer.removeAllAnimations()
            }
            updateCategoryDataArrayFrame()
            removeAllAndSaveCoreData()
            
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

//MARK: CollectionView
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else { return }
        
        cell.isCreated = true
        let createColor = UIColor.randomColor(from: 130, to: 220)
        categoryDataArr[indexPath.row].isCreated = true
        let createBtn = createRandomBubble(with: categoryImageArray[indexPath.row],
                                           in: nil,
                                           color: createColor)
        createBtn.addTarget(self, action: #selector(setBubbleCategory), for: .touchUpInside)
        createBtn.tag = indexPath.row
        selectedCatogoryRow = indexPath.row
        categoryDataArr[indexPath.row].button = createBtn
        categoryDataArr[indexPath.row].frame = createBtn.frame
        categoryDataArr[indexPath.row].color = createColor
        createBtn.layer.opacity = 0
        view.addSubview(createBtn)
        
        //float in animation
        createBtn.animation = "fadeInUp"
        createBtn.curve = "easeInOut"
        createBtn.duration = 2.5
        createBtn.damping = 10
        createBtn.velocity = 0.1
        createBtn.animate()
        createBtn.layer.opacity = 0.6
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else { return }
        categoryDataArr[indexPath.row].button.removeFromSuperview()
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

//MARK: Bubble Control
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
    
    func dragBubble(gesture: UIPanGestureRecognizer) {
        
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
                    
                case .setup:
                    
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

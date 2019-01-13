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
import AnimatedCollectionViewLayout
import SpriteKit

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
    let blackTransparentView = SpringView()
    var skView = SKView()
    
    @IBOutlet weak var categorysCollectionView: UICollectionView!
    var categoryScrollViewConstraint: NSLayoutConstraint?
    var colorPickerViewConstraint: NSLayoutConstraint?
    @IBOutlet weak var categoryDoneBtn: CategoryDoneButton!
    var categoryDataArr: [Category] = []
    var selectedCatogoryRow: Int = 0
    
    let colorPickerView = IGColorPickerView()
    
    var circleCenter: CGPoint! // record for bubble circle center
    var currentMode: Mode = .normal //record for distinguish drag out of view action
    var dragAnimatorArray: [UIViewPropertyAnimator] = []
    
    @IBOutlet weak var tipLabel: SpringLabel!
    var deleteLabelConstraint: NSLayoutConstraint?
    let tutorialScrollView = UIScrollView()
    var gestureQuitTutorial: UITapGestureRecognizer?
    
    var backgroundImageCollectionView: UICollectionView!
    var animator: (LayoutAttributesAnimator, Bool, Int, Int) = (LinearCardAttributesAnimator(), false, 1, 1)
    var direction: UICollectionView.ScrollDirection = .vertical
    let cellIdentifier = "BackgroundImageCollectionViewCell"
    
    var settingButtonTableView: UITableView!
    var settingButtonTableViewConstraint: NSLayoutConstraint?
    var exitSettingButton: UIButton!
    
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
        
        //settingButtonTableView
        settingButtonTableView = UITableView()
        settingButtonTableView.delegate = self
        settingButtonTableView.dataSource = self
        settingButtonTableView.register(UINib(nibName: "SettingButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingButtonTableViewCell")
        settingButtonTableView.separatorStyle = .none
        settingButtonTableView.backgroundColor = .clear
        settingButtonTableView.contentMode = .center
        settingButtonTableView.isScrollEnabled = false
        settingButtonTableView.allowsSelection = false
        view.addSubview(settingButtonTableView)
        settingButtonTableView.translatesAutoresizingMaskIntoConstraints = false
        settingButtonTableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        settingButtonTableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 5/12).isActive = true
        settingButtonTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        settingButtonTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        settingButtonTableViewConstraint = NSLayoutConstraint(item: settingButtonTableView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 1000)
        view.addConstraint(settingButtonTableViewConstraint!)

        //exit Button
        exitSettingButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.view.addSubview(exitSettingButton)
        self.exitSettingButton.isHidden = true
        exitSettingButton.translatesAutoresizingMaskIntoConstraints = false
        exitSettingButton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
        exitSettingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        exitSettingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        exitSettingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        exitSettingButton.setTitle("Exit", for: .normal)
        let color = UIColor(hex: "ff5252")
        exitSettingButton.setTitleColor(color, for: .normal)
        exitSettingButton.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 22)
        exitSettingButton.addTarget(self, action: #selector(exitSettingMode), for: .touchUpInside)
        
        //category
        categoryDoneBtn.addTarget(self, action: #selector(exitSettingMode), for: .touchUpInside)
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
        colorPickerView.bottomAnchor.constraint(equalTo: categorysCollectionView.topAnchor, constant: 0).isActive = true
        colorPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        colorPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        colorPickerViewConstraint = NSLayoutConstraint(item: colorPickerView, attribute: .top, relatedBy: .equal, toItem: categorysCollectionView, attribute: .top, multiplier: 1, constant: 0)
        view.addConstraint(colorPickerViewConstraint!)
        
        //backgroundImageCollectionView
        let layout = AnimatedCollectionViewLayout()
        backgroundImageCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        backgroundImageCollectionView.delegate = self
        backgroundImageCollectionView.dataSource = self
        backgroundImageCollectionView.register(UINib(nibName: "BackgroundImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BackgroundImageCollectionViewCell")
        backgroundImageCollectionView.isHidden = true
        backgroundImageCollectionView.frame = self.view.frame
        backgroundImageCollectionView.backgroundColor = rgbaToUIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 0)
        layout.scrollDirection = .horizontal
        layout.animator = animator.0
        backgroundImageCollectionView.collectionViewLayout = layout
        backgroundImageCollectionView.isPagingEnabled = true
        self.view.addSubview(backgroundImageCollectionView)
        
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
        tipLabel.isUserInteractionEnabled = true
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        tipLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        tipLabel.bottomAnchor.constraint(equalTo: colorPickerView.topAnchor, constant: 0).isActive = true
        tipLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        tipLabel.layer.borderWidth = 1.5
        tipLabel.layer.borderColor = UIColor.red.cgColor
        deleteLabelConstraint = NSLayoutConstraint(item: tipLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
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
        if let savedImage = readBackgroundImage() {
            backgroundImageView.image = savedImage
        } else {
            createBackgroundDataFirstTime()
        }
    }
    
    func readBackgroundImage() -> UIImage? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let moc = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserMO")
        do {
            guard let results = try moc.fetch(request) as? [UserMO] else {
                return nil
            }
            if results.count > 0 {
                let user = results[0]
                if let image = user.backgroundImage {
                    return UIImage(data: image as Data)
                }
            }
        } catch {
            fatalError("Core Data Update: \(error)")
        }
        return nil
    }
    
    func showupFirstTime() {
        
        addBlackTransparentView()
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            
            //bring views to front
            self.view.bringSubviewToFront(self.categorysCollectionView)
            self.view.bringSubviewToFront(self.colorPickerView)
            self.view.bringSubviewToFront(self.categoryDoneBtn)
            self.view.bringSubviewToFront(self.tipLabel)
            
            //button action & appearance change
            self.switchMode(to: .setupCategory)
            self.categoryScrollViewConstraint?.constant = -100
            self.colorPickerViewConstraint?.constant = -44
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
                self.alertLabel(replaceString: "Please choose categories", isHidden: false, color: .red)
            }, completion: { (completed) in
                
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
            }
        }
    }
    
    func createBackgroundDataFirstTime() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let moc = appDelegate.persistentContainer.viewContext
        if let entityDescription = NSEntityDescription.entity(forEntityName: "UserMO", in: moc) {
            let user = UserMO(entity: entityDescription, insertInto: moc)
            if let imageData = #imageLiteral(resourceName: "BK-beach sunrise").pngData() {
                user.backgroundImage = imageData 
            }
            appDelegate.saveContext()
        }
    }
    
    @objc func btnMenuBtn() {
        
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
    
    @objc func btnSettingBtn() {
        //dismiss menu button
        self.menuButton.isSelected = false
        self.settingButton.isHidden = true
        self.infoBtton.isHidden = true

        //blackTransparentView show up
        blackTransparentView.backgroundColor = .black
        view.addSubview(blackTransparentView)
        //TODO: backgroundImage Animation
        backgroundImageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 0)
        blackTransparentView.translatesAutoresizingMaskIntoConstraints = false
        blackTransparentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        blackTransparentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        blackTransparentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        blackTransparentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true

        blackTransparentView.animation = "fadeIn"
        blackTransparentView.duration = 0.5
        blackTransparentView.animateNext {

            self.exitSettingButton.isHidden = false
            self.view.bringSubviewToFront(self.exitSettingButton)
            self.view.bringSubviewToFront(self.settingButtonTableView)
            self.settingButtonTableView.cellshrinkAll(duration: 0)
            self.settingButtonTableViewConstraint?.constant = 0
            self.view.layoutIfNeeded()
            self.settingButtonTableView.cellEmergeOrderly(from: 0)
        }
        blackTransparentView.alpha = 0.8

        if quoteButton.isSelected {
            btnQuoteBtn(sender: quoteButton)
        }
    }
    
    func switchMode(to mode: Mode) {
        
        switch mode {
            
        case .normal:
            currentMode = .normal
            
            //logic
            for category in categoryDataArr {
                category.button.removeTarget(self, action: #selector(displayCategorySetup), for: .touchUpInside)
                category.button.addTarget(self, action: #selector(displayListView), for: .touchUpInside)
            }
            
            //views
            exitSettingButton.isHidden = true
            backgroundImageCollectionView.isHidden = true
        
            categoryScrollViewConstraint?.constant = 0
            colorPickerViewConstraint?.constant = 0
            deleteLabelConstraint?.constant = 0
            self.settingButtonTableViewConstraint?.constant = 1000
            
            if let image = readBackgroundImage() {
                self.backgroundImageView.image = image
            }
            
        case .setupCategory:
            currentMode = .setupCategory
            backgroundImageCollectionView.isHidden = true
            
            //bubble
            for category in categoryDataArr {
                category.button.removeTarget(self, action: #selector(displayListView), for: .touchUpInside)
                category.button.addTarget(self, action: #selector(displayCategorySetup), for: .touchUpInside)
            }
            
        case .setupBackground:
            currentMode = .setupBackground
        
        case .tutorial:
            let gesture = UITapGestureRecognizer(target: self, action: #selector(quitTutorial))
            gestureQuitTutorial = gesture
            tipLabel.addGestureRecognizer(gestureQuitTutorial!)
        }
    }
    
    @objc func displayCategorySetup(sender: UIButton) {
        switchMode(to: .setupCategory)
        
        self.blackTransparentView.alpha = 0.6
        self.settingButtonTableViewConstraint?.constant = 1000
        self.deleteLabelConstraint?.constant = 0
        
        view.bringSubviewToFront(blackTransparentView)
        view.bringSubviewToFront(categorysCollectionView)
        view.bringSubviewToFront(colorPickerView)
        view.bringSubviewToFront(categoryDoneBtn)
        view.bringSubviewToFront(tipLabel)
        for category in categoryDataArr {
            view.bringSubviewToFront(category.button)
        }
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
                        scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
                }
            }
            
            self.categorysCollectionView.scrollToItem(at: clickedIndexPath, at: .centeredHorizontally, animated: true)
            
        })
    }
    
    @objc func displayBackgroundSetup() {
        self.view.bringSubviewToFront(self.backgroundImageCollectionView)
        self.view.bringSubviewToFront(self.exitSettingButton)
        self.backgroundImageCollectionView.isHidden = false
        self.blackTransparentView.alpha = 0.6
        self.settingButtonTableViewConstraint?.constant = 1000
    }
    
    @objc func displayQuoteSetup() {
        let alert = UIAlertController(title: "", message: "Coming Soon...", preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (UIAlertAction) in
            self.skView.removeFromSuperview()
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
//        let offset:CGFloat = 50;
//        let skViewFrame = CGRect(x: self.view.frame.minX - offset,
//                                 y: self.view.frame.minY,
//                                 width: self.view.frame.width + offset*2,
//                                 height: self.view.frame.height)
//        skView = SKView(frame: skViewFrame)
//        skView.backgroundColor = .clear
//        self.view.addSubview(skView)
//        let scene = SpringScene(size: skView.bounds.size)
//        skView.ignoresSiblingOrder = true
//        scene.scaleMode = .resizeFill
//        skView.presentScene(scene)
//        exitSettingMode()
    }
    
    @objc func exitSettingMode() {
        
        //calculate count
        var count = 0
        for category in categoryDataArr {
            if category.isCreated {
                count += 1
            }
        }
        //check if category > 0
        if count > 0 {
            blackTransparentView.removeFromSuperview()
            switchMode(to: .normal)
            
            //update categoryDataArray
            updateCategoryDataArrayFrame()
            
            //TO DO: Core data save
            removeAllAndSaveCoreData()
            
        } else {
            alertLabel(replaceString: "please choose a category", isHidden: true, color: .red)
        }
    }
    
    func alertLabel(replaceString: String, isHidden: Bool, color: UIColor) {
        tipLabel.text = replaceString
        tipLabel.textColor = color
        tipLabel.layer.borderColor = color.cgColor
        let maxSize = CGSize(width: quoteView.frame.width - 10, height: view.frame.maxY)
        let size = tipLabel.sizeThatFits(maxSize)
        deleteLabelConstraint?.constant = size.width + 50
        view.layoutIfNeeded()
        tipLabel.isHidden = false
        tipLabel.animation = "fadeIn"
        tipLabel.animateNext {
            self.tipLabel.isHidden = isHidden
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
                cMO.color = category.color.encode()
            }
        }
        
        do {
            try moc.save()
            
        } catch { print(error.localizedDescription) }
        
    }
    
    @objc func btnInfoBtn() {
        
        self.menuButton.isSelected = false
        self.settingButton.isHidden = true
        self.infoBtton.isHidden = true
        
        addBlackTransparentView()
        
        //bring views to front
        view.bringSubviewToFront(tipLabel)
        
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
        backgroundImageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 0)
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
    
    @objc func quitTutorial() {
        tutorialScrollView.removeFromSuperview()
        tipLabel.removeGestureRecognizer(gestureQuitTutorial!)
        exitSettingMode()
    }
    
    @objc func btnQuoteBtn(sender: UIButton) {
        
        if !sender.isSelected {
            
            view.bringSubviewToFront(quoteView)
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
            }, completion: { [weak self] (_) in
                self?.quoteView.isHidden = false
                animateView.removeFromSuperview()
                sender.isEnabled = true
            })

        } else {
            dismissQuote()
        }
    }
    
    @objc func dismissQuote() {
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
        }, completion: { [weak self] (_) in
            self?.quoteLbl.removeFromSuperview()
            animateView.removeFromSuperview()
            self?.quoteButton.isEnabled = true
            self?.quoteButton.isSelected = false
        })
    }
    
    @objc func displayListView(sender: UIButton) {
        
        if let navigationVC = storyboard?.instantiateViewController(withIdentifier: "ListNavigationController") as? UINavigationController {
            
            //save frame
            for category in categoryDataArr {
                category.button.layer.removeAllAnimations()
            }
            updateCategoryDataArrayFrame()
            removeAllAndSaveCoreData()
            
            //send value
            guard let vc = navigationVC.children[0] as? ListViewController else { return }
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




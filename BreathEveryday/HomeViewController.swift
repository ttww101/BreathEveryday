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
import Spring

enum Mode {
    case normal
    case setup
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var quoteButton: SpringButton!
    @IBOutlet weak var weatherImageView: SpringImageView!
    @IBOutlet weak var quoteView: UIView!
    @IBOutlet weak var menuButton: SpringButton!
    @IBOutlet weak var shopBtton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    var quoteViewBottomConstraint: NSLayoutConstraint?
    let quoteLbl = UILabel()
    var isAnimating: Bool = false
    let blackTransparentView = SpringView()
    @IBOutlet weak var categorysCollectionView: UICollectionView!
    var categoryScrollViewConstraint: NSLayoutConstraint?
    var colorPickerViewConstraint: NSLayoutConstraint?
    @IBOutlet weak var categoryDoneBtn: UIButton!
    var categoryDataArr: [Category] = []
    var colorPickerView: ColorPickerView!
    var selectedCatogoryRow: Int = 0
    var circleCenter: CGPoint! // record for bubble circle center
    var currentMode: Mode = .normal //record for distinguish drag out of view action
    var dragAnimatorArray: [UIViewPropertyAnimator] = []
    @IBOutlet weak var deleteSuccessLabel: SpringLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controllerSetup()
        weatherImageView.animation = "morph"
        weatherImageView.animate()
        weatherImageView.animateNext {
            self.quoteButton.animation = "flash"
            self.quoteButton.animate()
            self.weatherImageView.animation = "morph"
            self.weatherImageView.animate()
        }
    }
    
    func controllerSetup() {
        
        //quote
        var image = #imageLiteral(resourceName: "Message-50").withRenderingMode(.alwaysTemplate)
        quoteButton.setImage(image, for: .normal)
        quoteButton.tintColor = UIColor.white
        image = #imageLiteral(resourceName: "Feedback-50").withRenderingMode(.alwaysTemplate)
        quoteButton.setImage(image, for: .selected)
        quoteButton.imageView?.contentMode = .scaleAspectFit
        quoteViewBottomConstraint = NSLayoutConstraint(item: quoteView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 25)
        view.addConstraint(quoteViewBottomConstraint!)
        quoteView.layer.borderColor = UIColor().middleGray().cgColor
        quoteView.backgroundColor = UIColor(colorLiteralRed: 245/255, green: 245/255, blue: 250/255, alpha: 0.9)
        quoteView.layer.borderWidth = 2
        quoteLbl.numberOfLines = 0
        quoteLbl.font = UIFont(name: "HelveticaNeue", size: 16)
        quoteLbl.adjustsFontSizeToFitWidth = true
        quoteButton.addTarget(self, action: #selector(btnQuoteBtn), for: .touchUpInside)
        quoteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissQuote)))
        
        //menu
        menuButton.alpha = 0.9
        shopBtton.alpha = 0.9
        settingButton.alpha = 0.9
        image = #imageLiteral(resourceName: "Thumbnails-48").withRenderingMode(.alwaysTemplate)
        menuButton.setImage(image, for: .normal)
        menuButton.tintColor = UIColor(colorLiteralRed: 192/255, green: 214/255, blue: 204/255, alpha: 1.0)
        menuButton.imageView?.contentMode = .scaleAspectFit
        image = #imageLiteral(resourceName: "Settings").withRenderingMode(.alwaysTemplate)
        settingButton.setImage(image, for: .normal)
//        settingButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2)
        settingButton.tintColor = UIColor.white
        settingButton.imageView?.contentMode = .scaleAspectFit
        image = #imageLiteral(resourceName: "Shop").withRenderingMode(.alwaysTemplate)
        shopBtton.setImage(image, for: .normal)
        shopBtton.tintColor = UIColor.white
        shopBtton.imageView?.contentMode = .scaleAspectFit
        shopBtton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        menuButton.addTarget(self, action: #selector(btnMenuBtn), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(btnSettingBtn), for: .touchUpInside)
        shopBtton.addTarget(self, action: #selector(btnShopBtn), for: .touchUpInside)
        
        //category
        image = #imageLiteral(resourceName: "Checkmark Filled-50").withRenderingMode(.alwaysTemplate)
        categoryDoneBtn.setImage(image, for: .normal)
        categoryDoneBtn.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 0, 15)
        categoryDoneBtn.imageView?.contentMode = .scaleAspectFit
        categoryDoneBtn.addTarget(self, action: #selector(btnDone), for: .touchUpInside)
        categoryDoneBtn.tintColor = UIColor().greenAirwaves()
        categoryDoneBtn.setTitleColor(UIColor().greenAirwaves(), for: .normal)
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
        colorPickerView.colors =  [#colorLiteral(red: 1, green: 0.5411764706, blue: 0.5019607843, alpha: 1), #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1),
                                   #colorLiteral(red: 1, green: 0.8196078431, blue: 0.5019607843, alpha: 1), #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1),
                                   #colorLiteral(red: 1, green: 0.6196078431, blue: 0.5019607843, alpha: 1), #colorLiteral(red: 1, green: 0.2392156863, blue: 0, alpha: 1), #colorLiteral(red: 0.8666666667, green: 0.1725490196, blue: 0, alpha: 1),
                                   #colorLiteral(red: 1, green: 1, blue: 0.5529411765, alpha: 1), #colorLiteral(red: 1, green: 0.9176470588, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.8392156863, blue: 0, alpha: 1),
                                   #colorLiteral(red: 0.7254901961, green: 0.9647058824, blue: 0.7921568627, alpha: 1), #colorLiteral(red: 0, green: 0.9019607843, blue: 0.462745098, alpha: 1), #colorLiteral(red: 0, green: 0.7843137255, blue: 0.3254901961, alpha: 1),
                                   #colorLiteral(red: 0.5176470588, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.8980392157, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.7215686275, blue: 0.831372549, alpha: 1),
                                   #colorLiteral(red: 0.5019607843, green: 0.8470588235, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.568627451, blue: 0.9176470588, alpha: 1),
                                   #colorLiteral(red: 0.5490196078, green: 0.6196078431, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.568627451, blue: 0.9176470588, alpha: 1),
                                   #colorLiteral(red: 0.9176470588, green: 0.5019607843, blue: 0.9882352941, alpha: 1), #colorLiteral(red: 0.8352941176, green: 0, blue: 0.9764705882, alpha: 1), #colorLiteral(red: 0.6666666667, green: 0, blue: 1, alpha: 1),
                                   #colorLiteral(red: 0.7019607843, green: 0.5333333333, blue: 1, alpha: 1), #colorLiteral(red: 0.3960784314, green: 0.1215686275, blue: 1, alpha: 1), #colorLiteral(red: 0.3843137255, green: 0, blue: 0.9176470588, alpha: 1),
                                   #colorLiteral(red: 0.737254902, green: 0.6666666667, blue: 0.6431372549, alpha: 1), #colorLiteral(red: 0.4745098039, green: 0.3333333333, blue: 0.2823529412, alpha: 1), #colorLiteral(red: 0.3058823529, green: 0.2039215686, blue: 0.1803921569, alpha: 1),
                                   #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1), #colorLiteral(red: 0.3803921569, green: 0.3803921569, blue: 0.3803921569, alpha: 1), #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)]
        
        
        view.addSubview(colorPickerView)
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        colorPickerView.topAnchor.constraint(equalTo: categorysCollectionView.topAnchor, constant: 300).isActive = true
        colorPickerView.bottomAnchor.constraint(equalTo: categorysCollectionView.topAnchor, constant: 0).isActive = true
        colorPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        colorPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        colorPickerViewConstraint = NSLayoutConstraint(item: colorPickerView, attribute: .top, relatedBy: .equal, toItem: categorysCollectionView, attribute: .top, multiplier: 1, constant: 0)
        view.addConstraint(colorPickerViewConstraint!)
        
        //Bubbles
        //read data & create & transfer data
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
        
        //deleteLabel
        deleteSuccessLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteSuccessLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        deleteSuccessLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        deleteSuccessLabel.bottomAnchor.constraint(equalTo: colorPickerView.topAnchor, constant: 0).isActive = true
        deleteSuccessLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
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
        blackTransparentView.animation = "fadeIn"
        blackTransparentView.duration = 1
        blackTransparentView.animate()
        blackTransparentView.alpha = 0.75
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            
            //send views to front
            self.view.bringSubview(toFront: self.categorysCollectionView)
            self.view.bringSubview(toFront: self.colorPickerView)
            self.view.bringSubview(toFront: self.categoryDoneBtn)
            self.view.bringSubview(toFront: self.deleteSuccessLabel)
            
            //button action & appearance change
            self.swichMode(to: .setup)
            self.categoryScrollViewConstraint?.constant = -100
            self.colorPickerViewConstraint?.constant = -44
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in })
        })
        
    }
    
    func createRandomBubble(with image: UIImage, in frame: CGRect?, color: UIColor) -> UIButton {
        
        let button = SpringButton()
        if let frame = frame {
            button.layer.frame = frame
        } else {
            let xPos = arc4random_uniform(UInt32(view.frame.width) - 100)
            let yPos = arc4random_uniform(UInt32(colorPickerView.frame.minY) - 100 - UInt32(quoteButton.frame.maxY)) + UInt32(quoteButton.frame.maxY)
            button.layer.frame = CGRect(x: Int(xPos), y: Int(yPos), width: 84, height: 84)
        }
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.frame.width / 2
        button.backgroundColor = color
        button.layer.opacity = 0.6
        
        //image1
        let imageRendered = image.withRenderingMode(.alwaysTemplate)
        button.tintColor = UIColor.white
        button.setImage(imageRendered, for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
        
        //gesture
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(dragCircle))
        button.addGestureRecognizer(gesture)
        
        return button
    }
    
    func dragCircle(gesture: UIPanGestureRecognizer) {
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
//            let springParameters = UISpringTimingParameters(mass: 5, stiffness: 70, damping: 30, initialVelocity: cgVelocity)
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
                    
                    target.center = CGPoint(x: stopPoint_X, y: stopPoint_Y)
                    target.transform = CGAffineTransform.identity
                    
                    if 25 <= stopPoint_X && stopPoint_X <= self.view.frame.maxX - 25 &&
                        25 <= stopPoint_Y && stopPoint_Y <= self.view.frame.maxY - 25 {
                    } else {
                        
                        var countForCreated = 0
                        var isLastBubble = true
                        for category in self.categoryDataArr {
                            if category.isCreated {
                                countForCreated += 1
                            }
                            if countForCreated > 1 {
                                isLastBubble = false
                                break
                            }
                        }
                        //MARK: Delete bubble data
                        if !isLastBubble {
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
                    }
                }
                
            }
            bubbleAnimator.startAnimation()
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
                target.layer.opacity = 0.6 //
            }
            
        default:
            break
        }
        
        //delete animation
        if isDeleteSuccess {
            deleteSuccessLabel.isHidden = false
            deleteSuccessLabel.animation = "fadeIn"
            deleteSuccessLabel.animateNext {
                self.deleteSuccessLabel.isHidden = true
            }
        }
    }
    
    func flip(with firstView: UIView) {
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        
        let secondView = firstView
        view.addSubview(secondView)
        
        UIView.transition(with: firstView, duration: 1.0, options: transitionOptions, animations: {
            firstView.isHidden = true
        })
        
        UIView.transition(with: secondView, duration: 1.0, options: transitionOptions, animations: {
            secondView.isHidden = false
        })
    }
    
    func flipAction() {
        
    }
    
    func btnMenuBtn() {
        
        if !menuButton.isSelected {
            menuButton.rotate = 720
            menuButton.animation = "linear"
            menuButton.force = 0
            menuButton.duration = 1
            menuButton.animate()
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
        
        menuButton.rotate = -720
        menuButton.animation = "linear"
        menuButton.force = 0
        menuButton.duration = 1
        menuButton.animate()
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
        
        
        blackTransparentView.animation = "fadeIn"
        blackTransparentView.duration = 1
        blackTransparentView.animate()
        blackTransparentView.alpha = 0.75
        
        //send views to front
        view.bringSubview(toFront: quoteButton)
        view.bringSubview(toFront: categorysCollectionView)
        view.bringSubview(toFront: colorPickerView)
        view.bringSubview(toFront: categoryDoneBtn)
        view.bringSubview(toFront: deleteSuccessLabel)
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
            currentMode = .normal
            for category in categoryDataArr {
                category.button.removeTarget(self, action: #selector(displayCategoryScrollView), for: .touchUpInside)
                category.button.addTarget(self, action: #selector(displayListView), for: .touchUpInside)
            }
            
            let image = #imageLiteral(resourceName: "Message-50").withRenderingMode(.alwaysTemplate)
            quoteButton.setImage(image, for: .normal)
            quoteButton.tintColor = .black
            quoteButton.removeTarget(self, action: #selector(btnQuoteBtnSettingMode), for: .touchUpInside)
            quoteButton.addTarget(self, action: #selector(btnQuoteBtn), for: .touchUpInside)
            
        case .setup:
            //button targets
            currentMode = .setup
            for category in categoryDataArr {
                category.button.removeTarget(self, action: #selector(displayListView), for: .touchUpInside)
                category.button.addTarget(self, action: #selector(displayCategoryScrollView), for: .touchUpInside)
            }
            
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
        colorPickerViewConstraint?.constant = -44
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
            
            //update categoryDataArray
            
            updateCategoryDataArrayFrame()
            
            //MARK: Core data save
            
            removeAllAndSaveCoreData()
            
        } else {
            //TODO: alert nothing selected
            //alsert animation
            deleteSuccessLabel.text = "please choose an category"
            deleteSuccessLabel.isHidden = false
            deleteSuccessLabel.animation = "fadeIn"
            deleteSuccessLabel.animateNext {
                self.deleteSuccessLabel.isHidden = true
                self.deleteSuccessLabel.text = "delete success"
            }
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
        return CGSize(width: 25, height: 25)
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




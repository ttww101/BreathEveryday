//
//  ViewController.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/3/20.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var quoteButton: UIButton!
    @IBOutlet weak var quoteView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var shopBtton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    var quoteViewBottomConstraint: NSLayoutConstraint?
    let quoteLbl = UILabel()
    var isAnimating: Bool = false
    var bubblesBtn: [UIButton] = []
    var bubblesImage: [UIImageView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createBubble()
        setupView()
    }
    
    func setupView() {
        
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
    }
    
    func createBubble() {
        
        let button1 = UIButton()
        let image1 = UIImageView()
        bubblesBtn.append(button1)
        bubblesImage.append(image1)
        
        //button1
        button1.layer.frame = CGRect(x: 100, y: 200, width: 100, height: 100)
        button1.layer.masksToBounds = true
        button1.layer.cornerRadius = 50
        button1.backgroundColor = UIColor.lightGray
        button1.addTarget(self, action: #selector(displayListView), for: .touchUpInside)
        view.addSubview(button1)

        //image1
        image1.image = #imageLiteral(resourceName: "Shopping Cart-50")
        image1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(displayListView)))
        image1.layer.frame = CGRect(x: 20, y: 20, width: button1.frame.width - 40, height: button1.frame.height - 40)
        button1.addSubview(image1)
        
        view.sendSubview(toBack: button1)
        view.sendSubview(toBack: image1)
    }
    
    func btnMenuBtn() {
        
        if !menuButton.isSelected {
            menuButton.isEnabled = false
            menuButton.isSelected = true
            settingButton.isHidden = false
            shopBtton.isHidden = false
            menuButton.isEnabled = true
        } else {
            menuButton.isEnabled = false
            menuButton.isSelected = false
            settingButton.isHidden = true
            shopBtton.isHidden = true
            menuButton.isEnabled = true
        }
        
    }
    
    func btnSettingBtn() {
        
    }
    func btnShopBtn() {
        
    }
    
    func btnQuoteBtn(sender: UIButton) {
        
        if !sender.isSelected {
            
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
    
    func displayListView() {
        
        if let displayView = storyboard?.instantiateViewController(withIdentifier: Identifier.listView.rawValue) as? UINavigationController {
            
            let subView = UIView()
            subView.layer.frame = displayView.view.frame
            subView.backgroundColor = UIColor.white
            displayView.view.addSubview(subView)
            subView.layer.opacity = 1
            
            self.present(displayView, animated: false, completion: {
                UIView.animate(withDuration: 0.5, animations: {
                    subView.layer.opacity = 0.0
                }, completion: { (_) in
                    subView.removeFromSuperview()
                })
            })
        }

    }
}

var numberOfQuote = 0
let quotes:[String] = ["Steve Jobs - \nIf today was the last day of my life would I want to do what I’m about to do today?",
                       "Kobe Bryant - \nI don't talk trash often, but when I do, I go for the jugular.",
                       "William James - \nBe not afraid of life. Believe that life is worth living, and your belief will help create the fact.",
                       "Erma Bombeck - \nWhen I stand before God at the end of my life, I would hope that I would not have a single bit of talent left and could say, I used everything you gave me.",
                       "Mark Twain - \nThe secret of getting ahead is getting started.",
                       "Benjamin Disraeli - \nNurture your mind with great thoughts. To believe in the heroic makes heroes.",
                       "Ray Kroc - \nLuck is a dividend of sweat. The more you sweat, the luckier you get.",
                       "Carol Burnett - \nOnly I can change my life. No one can do it for me.",
                       "George Sand - \nThere is only one happiness in this life, to love and be loved.",
                       "Charles R. Swindoll - \nLife is 10% what happens to you and 90% how you react to it.",
                       "English Proverb - \nYou may find the worst enemy or best friend in yourself.",
                       "Vincent Van Gogh - \nWhoever loves much, performs much, and can accomplish much, and what is done in love is done well.",
                       "Winston Churchill - \nCourage is the first of human qualities because it is the quality which guarantees all others.",
                       "Oliver Wendell Holmes - The great thing in this world is not so much where you stand, as in what direction you are moving.",
                       "Arthur Schopenhauer - \nEvery truth passes through three stages before it is recognized. In the first, it is ridiculed. In the second, it is opposed. In the third, it is regarded as self evident.",
                       "Jim Rohn - \nEither you run the day, or the day runs you.",
                       "Vince Lombardi - \nThe difference between a successful person and others is not lack of strength not a lack of knowledge but rather a lack of will.",
                       "John F. Kennedy - \nIf not us, who? If not now, when?",
                       "Carl Bard - \nThough no one can go back and make a brand new start, anyone can start from now and make a brand new ending.",
                       "George Bernard Shaw - \nSome men see things as they are and say why – I dream things that never were and say why not.",
                       "William Shakespeare - \nSpeak less than you know; have more than you show.",
                       "Thomas Edison - \nMany of life’s failures are experienced by people who did not realize how close they were to success when they gave up.",
                       "Joe Clark - \nDefeat is not bitter unless you swallow it.",
                       "Larry Winget - Nobody ever wrote down a plan to be broke, fat, lazy, or stupid. Those things are what happen when you don’t have a plan.",
                       "Bomi Chen - Do what makes you happy. :)",
                       "Joshua J. Marine - \nChallenges are what make life interesting and overcoming them is what makes life meaningful.",
                       "Mark Twain - \nKeep away from people who try to belittle your ambitions. Small people always do that, but the really great makes you feel that you, too, can become great.",
                       "Albert Einstein - \nI am thankful for all of those who said NO to me. Its because of them I’m doing it myself.",
                       "Bruce Lee - \nI fear not the man who has practiced 10,000 kicks once, but I fear the man who has practiced one kick 10,000 times.",
                       "John Lennon - \nWhen I was 5 years old, my mother always told me that happiness was the key to life. When I went to school, they asked me what I wanted to be when I grew up. I wrote down ‘happy’. They told me I didn’t understand the assignment, and I told them they didn’t understand life.",
                       "Walt Disney - \nThere is more treasure in books than in all the pirate’s loot on Treasure Island."]






//
//  SelectImageCollectionViewController.swift
//  BreathEveryday
//
//  Created by Bomi on 2017/9/14.
//  Copyright © 2017年 Bomi. All rights reserved.
//


import UIKit
import AnimatedCollectionViewLayout

class SeleteImageCollectionViewController: UICollectionViewController {
    
    var animator: (LayoutAttributesAnimator, Bool, Int, Int) = (LinearCardAttributesAnimator(), false, 1, 1)
    var direction: UICollectionViewScrollDirection = .vertical
    let cellIdentifier = "BackgroundImageCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        collectionView?.isPagingEnabled = true
        
        let layout = AnimatedCollectionViewLayout()
        layout.scrollDirection = .horizontal
        layout.animator = animator.0
        collectionView?.collectionViewLayout = layout
        
        let dismissGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        dismissGesture.direction = .down
        self.view.addGestureRecognizer(dismissGesture)
    }
    
    @objc func swipeDown() {
        dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool { return true }
}

extension SeleteImageCollectionViewController: UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        
        if let cell = c as? BackgroundImageCollectionViewCell {
            cell.clipsToBounds = animator.1
            switch indexPath.row {
            case 0:
                cell.backgroundImageView.image = #imageLiteral(resourceName: "BK-beach sunrise")
            case 1:
                cell.backgroundImageView.image = #imageLiteral(resourceName: "BK-beach sunset")
            case 2:
                cell.backgroundImageView.image = #imageLiteral(resourceName: "BK-luka")
            case 3:
                cell.backgroundImageView.image = #imageLiteral(resourceName: "BK-forest1")
            case 4:
                cell.backgroundImageView.image = #imageLiteral(resourceName: "BK-galaxy")
            case 5:
                cell.backgroundImageView.image = #imageLiteral(resourceName: "BK-Sword of Orion")
            default:
                break
            }
        }
        
        return c
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width / CGFloat(animator.2), height: view.bounds.height / CGFloat(animator.3))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

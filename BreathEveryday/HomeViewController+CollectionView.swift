//
//  HomeViewController+CollectionView.swift
//  BreathEveryday
//
//  Created by Bomi on 2017/9/25.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import AnimatedCollectionViewLayout

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.categorysCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else { return }
            
            cell.isCreated = true
            let createColor = UIColor.randomColor(from: 130, to: 220)
            categoryDataArr[indexPath.row].isCreated = true
            let createBtn = createRandomBubble(with: categoryImageArray[indexPath.row],
                                               in: nil,
                                               color: createColor)
            createBtn.addTarget(self, action: #selector(displayCategorySetup), for: .touchUpInside)
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
        } else if collectionView == backgroundImageCollectionView {
            if indexPath.row >= 6 {
                presentFusumaViewController()
            } else {
                let image = backgroundImageArray[indexPath.row]
                self.saveBackgroundImage(for: image)
                self.changeBackgroundView(for: image)
                backgroundImageCollectionView.isHidden = true
                self.exitSettingButton.isHidden = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if collectionView == self.categorysCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else { return }
            categoryDataArr[indexPath.row].button.removeFromSuperview()
            cell.isCreated = false
            categoryDataArr[indexPath.row].isCreated = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == self.backgroundImageCollectionView {
            var visibleRect = CGRect()
            visibleRect.origin = self.backgroundImageCollectionView.contentOffset
            visibleRect.size = self.backgroundImageCollectionView.bounds.size
            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
            if let visibleIndexPath: IndexPath = self.backgroundImageCollectionView.indexPathForItem(at: visiblePoint),let cell = backgroundImageCollectionView.cellForItem(at: visibleIndexPath) as? BackgroundImageCollectionViewCell {
                if visibleIndexPath.row != 6 {
                    self.backgroundImageView.image = cell.backgroundImageView.image
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.categorysCollectionView {
            return categoryDataArr.count
        }
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.categorysCollectionView {
            return CGSize(width: 99, height: 80)
        }
        return CGSize(width: view.bounds.width / CGFloat(animator.2), height: view.bounds.height / CGFloat(animator.3))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.categorysCollectionView {
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.categorysCollectionView {
            return 10
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.categorysCollectionView {
            return 10
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.categorysCollectionView {
            guard let cell = categorysCollectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
            //        cell.colorBK = categoryDataArr[indexPath.row].color
            cell.configureCell()
            cell.label.text = categoryDataArr[indexPath.row].name
            let image = categoryDataArr[indexPath.row].image
            cell.imageView.image = image
            cell.isCreated = categoryDataArr[indexPath.row].isCreated
            return cell
        } else if collectionView == self.backgroundImageCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BackgroundImageCollectionViewCell", for: indexPath) as! BackgroundImageCollectionViewCell
            cell.clipsToBounds = animator.1
            switch indexPath.row {
            case 6:
                cell.backgroundImageView.image = nil
                cell.photoImageView.image = #imageLiteral(resourceName: "Add Image").withRenderingMode(.alwaysTemplate)
                cell.backgroundImageView.layer.borderColor = UIColor.white.cgColor
                cell.backgroundImageView.layer.borderWidth = 5
                cell.backgroundColor = .darkGreyTransparent()
            default:
                cell.backgroundImageView.image = backgroundImageArray[indexPath.row]
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == backgroundImageCollectionView {
            if indexPath.row == 6 {
                if let cell = cell as? BackgroundImageCollectionViewCell {
                    cell.backgroundImageView.layer.borderWidth = 0
                    cell.photoImageView.image = nil
                    cell.backgroundColor = .clear
                }
            }
        }
    }
    
}

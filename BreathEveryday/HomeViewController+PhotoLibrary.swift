//
//  HomeViewController+PhotoLibrary.swift
//  BreathEveryday
//
//  Created by Bomi on 2017/8/30.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import Photos
import Fusuma
import TOCropViewController
import CoreData

extension HomeViewController: FusumaDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
    }
    
    //CropViewController
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        
        cropViewController.dismiss(animated: true) {
            self.saveBackgroundImage(for: image)
            self.changeBackgroundView(for: image)
        }
        
    }
    
    func changeBackgroundView(for image: UIImage) {
        self.backgroundImageCollectionView.isHidden = true
        self.backgroundImageView.image = image
        self.blackTransparentView.removeFromSuperview()
        self.switchMode(to: .normal)
    }
    
    func saveBackgroundImage(for image:UIImage) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let moc = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserMO")
        do {
            guard let results = try moc.fetch(request) as? [UserMO] else {
                return
            }
            let user = results[0]
            if let imageData = image.pngData() {
                user.backgroundImage = imageData
            }
            appDelegate.saveContext()
            
        } catch {
            
            fatalError("Core Data Update: \(error)")
        }
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true) {
            self.presentFusumaViewController()
        }
    }
    
    //FUSUMA
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        let cropViewController = TOCropViewController(image: image)
        cropViewController.delegate = self
        DispatchQueue.main.async {
            self.present(cropViewController, animated: true, completion: nil)
        }
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) { }
    
    func fusumaCameraRollUnauthorized() {
        
        //TODO: GO TO SETTINGS
    }
    
    func presentFusumaViewController() {
        
        let fusumaViewController = FusumaViewController()
        fusumaViewController.delegate = self
        fusumaCropImage = false
        fusumaBackgroundColor = UIColor.black.lighter(amount: 0.15)
        fusumaTintColor = .white
        fusumaCameraRollTitle = "Background"
        fusumaCameraTitle = "Background"
        self.present(fusumaViewController, animated: true) {
        }
    }
    
}


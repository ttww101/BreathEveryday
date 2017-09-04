//
//  HomeViewController+ColorPicker.swift
//  BreathEveryday
//
//  Created by Bomi on 2017/8/30.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import IGColorPicker
extension HomeViewController: ColorPickerViewDelegate {
    
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        
        //bubble selected
        categoryDataArr[selectedCatogoryRow].button.setBubbleColor(with: colorPickerView.colors[indexPath.row])
        
        //save color
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
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
}

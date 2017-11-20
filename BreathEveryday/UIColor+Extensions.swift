//
//  ColorModel.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/5/5.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func color(withData data:Data) -> UIColor {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as! UIColor
    }
    
    func encode()-> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
    
    class func randomColor(from beginNum: Int, to endNum: Int)-> UIColor {
        
        let range = UInt32(endNum - beginNum)
        let red = CGFloat(arc4random_uniform(range)) + CGFloat(beginNum)
        let green = CGFloat(arc4random_uniform(range)) + CGFloat(beginNum)
        let blue = CGFloat(arc4random_uniform(range)) + CGFloat(beginNum)
        let color = UIColor(displayP3Red: red/255, green: green/255, blue: blue/255, alpha: 1)
        
        return color
    }
    
    class func darkPurple() -> UIColor {
        return UIColor(displayP3Red: 61/255,
                       green: 57/255,
                       blue: 66/255,
                       alpha: 1)
    }
    
    class func blueMiddleGray() -> UIColor {
        return UIColor(displayP3Red: 163/255, green: 194/255, blue: 186/255, alpha: 1.0)
    }
    
    class func blueMiddleGrayLight() -> UIColor {
        return UIColor(displayP3Red: 192/255, green: 214/255, blue: 204/255, alpha: 1.0)
    }
    
    class func middleGray() -> UIColor {
        return UIColor(displayP3Red: 161/255, green: 177/255, blue: 166/255, alpha: 1.0)
    }
    
    class func greenAirwaves() -> UIColor {
        return UIColor(displayP3Red: 111/255, green: 191/255, blue: 152/255, alpha: 1.0)
    }
    
    class func blackTransparent() -> UIColor {
        return UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.95)
    }
    
    class func darkGreyTransparent() -> UIColor {
        return UIColor(displayP3Red: 25/255, green: 25/255, blue: 25/255, alpha: 0.98)
    }
    
    class func arrayOfCategoriesSetup() -> [UIColor] {
        
        var colorArray:[UIColor] = []
        
        colorArray.append(contentsOf: [#colorLiteral(red: 1, green: 0.7176470588, blue: 0.8666666667, alpha: 1), #colorLiteral(red: 1, green: 0.8, blue: 0.8, alpha: 1), #colorLiteral(red: 1, green: 0.7843137255, blue: 0.7058823529, alpha: 1), #colorLiteral(red: 1, green: 0.8666666667, blue: 0.6666666667, alpha: 1), #colorLiteral(red: 1, green: 0.9333333333, blue: 0.6, alpha: 1), #colorLiteral(red: 0.7450980392, green: 0.9647058824, blue: 0.7960784314, alpha: 1), #colorLiteral(red: 0.8, green: 0.9333333333, blue: 1, alpha: 1), #colorLiteral(red: 0.8, green: 0.8666666667, blue: 1, alpha: 1), #colorLiteral(red: 0.8, green: 0.8, blue: 1, alpha: 1), #colorLiteral(red: 0.9098039216, green: 0.8, blue: 1, alpha: 1)] )
        
        colorArray.append(contentsOf: [#colorLiteral(red: 1, green: 0.7333333333, blue: 0.9333333333, alpha: 1), #colorLiteral(red: 1, green: 0.7333333333, blue: 0.8666666667, alpha: 1), #colorLiteral(red: 1, green: 0.7333333333, blue: 0.8, alpha: 1), #colorLiteral(red: 1, green: 0.7333333333, blue: 0.7333333333, alpha: 1), #colorLiteral(red: 1, green: 0.7333333333, blue: 0.6666666667, alpha: 1),
                                       #colorLiteral(red: 1, green: 0.6, blue: 0.6, alpha: 1), #colorLiteral(red: 1, green: 0.4666666667, blue: 0.4666666667, alpha: 1), #colorLiteral(red: 1, green: 0.3333333333, blue: 0.3333333333, alpha: 1), #colorLiteral(red: 1, green: 0.2, blue: 0.2, alpha: 1),
                                       #colorLiteral(red: 1, green: 0.3529411765, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.4549019608, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.5529411765, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.6549019608, blue: 0.3058823529, alpha: 1),
                                       #colorLiteral(red: 0.9607843137, green: 0.8784313725, blue: 0.4470588235, alpha: 1), #colorLiteral(red: 0.9921568627, green: 0.8235294118, blue: 0.3058823529, alpha: 1), #colorLiteral(red: 0.8784313725, green: 0.7764705882, blue: 0, alpha: 1), #colorLiteral(red: 0.9058823529, green: 0.8431372549, blue: 0.03529411765, alpha: 1), #colorLiteral(red: 0.9568627451, green: 0.862745098, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.9137254902, blue: 0.1294117647, alpha: 1),
                                       #colorLiteral(red: 0.8705882353, green: 0.9411764706, blue: 0.6745098039, alpha: 1), #colorLiteral(red: 0.7490196078, green: 0.8588235294, blue: 0.5960784314, alpha: 1), #colorLiteral(red: 0.4941176471, green: 0.7568627451, blue: 0.4862745098, alpha: 1), #colorLiteral(red: 0.4, green: 0.6705882353, blue: 0.4705882353, alpha: 1), #colorLiteral(red: 0.2862745098, green: 0.5725490196, blue: 0.3921568627, alpha: 1), #colorLiteral(red: 0.3058823529, green: 0.7098039216, blue: 0.5294117647, alpha: 1), #colorLiteral(red: 0.5411764706, green: 0.9098039216, blue: 0.6862745098, alpha: 1), #colorLiteral(red: 0.462745098, green: 0.9176470588, blue: 0.8156862745, alpha: 1), #colorLiteral(red: 0.6588235294, green: 0.9058823529, blue: 0.8117647059, alpha: 1),
                                       #colorLiteral(red: 0.7843137255, green: 0.8980392157, blue: 1, alpha: 1), #colorLiteral(red: 0.462745098, green: 0.8431372549, blue: 0.9176470588, alpha: 1), #colorLiteral(red: 0.2039215686, green: 0.7058823529, blue: 0.9333333333, alpha: 1), #colorLiteral(red: 0.06666666667, green: 0.7411764706, blue: 0.9254901961, alpha: 1), #colorLiteral(red: 0.3921568627, green: 0.7058823529, blue: 0.9333333333, alpha: 1), #colorLiteral(red: 0.06274509804, green: 0.5058823529, blue: 0.8980392157, alpha: 1), #colorLiteral(red: 0.3333333333, green: 0.368627451, blue: 0.9333333333, alpha: 1),
                                       #colorLiteral(red: 0.4666666667, green: 0.4941176471, blue: 0.9333333333, alpha: 1), #colorLiteral(red: 0.6, green: 0.6196078431, blue: 0.9333333333, alpha: 1), #colorLiteral(red: 0.6392156863, green: 0.5960784314, blue: 0.9019607843, alpha: 1), #colorLiteral(red: 0.7529411765, green: 0.7019607843, blue: 0.9450980392, alpha: 1), #colorLiteral(red: 0.831372549, green: 0.7843137255, blue: 0.9725490196, alpha: 1)])
        
        colorArray.append(contentsOf: [#colorLiteral(red: 1, green: 0.5333333333, blue: 0.5333333333, alpha: 1), #colorLiteral(red: 1, green: 0.6431372549, blue: 0.5333333333, alpha: 1),
                                       #colorLiteral(red: 1, green: 0.7333333333, blue: 0.4, alpha: 1), #colorLiteral(red: 1, green: 0.8666666667, blue: 0.3333333333, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 0.4666666667, alpha: 1),
                                       #colorLiteral(red: 0.8666666667, green: 1, blue: 0.4666666667, alpha: 1), #colorLiteral(red: 0.7333333333, green: 1, blue: 0.4, alpha: 1), #colorLiteral(red: 0.4, green: 0.9215686275, blue: 0.4, alpha: 1), #colorLiteral(red: 0.6, green: 1, blue: 0.6, alpha: 1),
                                       #colorLiteral(red: 0.4666666667, green: 1, blue: 0.8, alpha: 1), #colorLiteral(red: 0.4666666667, green: 1, blue: 0.9333333333, alpha: 1), #colorLiteral(red: 0.4, green: 1, blue: 1, alpha: 1),
                                       #colorLiteral(red: 0.4666666667, green: 0.8666666667, blue: 1, alpha: 1), #colorLiteral(red: 0.6, green: 0.7333333333, blue: 1, alpha: 1), #colorLiteral(red: 0.6, green: 0.6, blue: 1, alpha: 1),
                                       #colorLiteral(red: 0.6235294118, green: 0.5333333333, blue: 1, alpha: 1), #colorLiteral(red: 0.6901960784, green: 0.5333333333, blue: 1, alpha: 1), #colorLiteral(red: 0.8235294118, green: 0.5568627451, blue: 1, alpha: 1),
                                       #colorLiteral(red: 0.9411764706, green: 0.7333333333, blue: 1, alpha: 1), #colorLiteral(red: 0.8901960784, green: 0.5568627451, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.4666666667, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.5333333333, blue: 0.7607843137, alpha: 1)])
        
        colorArray.append(contentsOf: [#colorLiteral(red: 0.9607843137, green: 0.8980392157, blue: 0.6352941176, alpha: 1), #colorLiteral(red: 0.9607843137, green: 0.8352941176, blue: 0.6352941176, alpha: 1), #colorLiteral(red: 1, green: 0.8235294118, blue: 0.7019607843, alpha: 1), #colorLiteral(red: 0.9607843137, green: 0.7725490196, blue: 0.6352941176, alpha: 1), #colorLiteral(red: 0.9607843137, green: 0.7098039216, blue: 0.6352941176, alpha: 1), #colorLiteral(red: 0.9607843137, green: 0.6470588235, blue: 0.6352941176, alpha: 1), #colorLiteral(red: 1, green: 0.6588235294, blue: 0.6431372549, alpha: 1), #colorLiteral(red: 1, green: 0.5490196078, blue: 0.5803921569, alpha: 1)])
        colorArray.append(contentsOf: [#colorLiteral(red: 0.9843137255, green: 0.6078431373, blue: 0.6078431373, alpha: 1), #colorLiteral(red: 0.8470588235, green: 0.4117647059, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.7647058824, green: 0.3176470588, blue: 0.3176470588, alpha: 1), #colorLiteral(red: 0.7411764706, green: 0.2274509804, blue: 0.2274509804, alpha: 1)])
        colorArray.append(contentsOf: [#colorLiteral(red: 0.8901960784, green: 0.8470588235, blue: 0.8470588235, alpha: 1), #colorLiteral(red: 0.6980392157, green: 0.6431372549, blue: 0.6431372549, alpha: 1), #colorLiteral(red: 0.6039215686, green: 0.5411764706, blue: 0.5411764706, alpha: 1), #colorLiteral(red: 0.4549019608, green: 0.368627451, blue: 0.368627451, alpha: 1), #colorLiteral(red: 0.4117647059, green: 0.3176470588, blue: 0.3176470588, alpha: 1),
                                       #colorLiteral(red: 0.4941176471, green: 0.4392156863, blue: 0.4941176471, alpha: 1), #colorLiteral(red: 0.5490196078, green: 0.5098039216, blue: 0.5960784314, alpha: 1), #colorLiteral(red: 0.6156862745, green: 0.6235294118, blue: 0.7137254902, alpha: 1), #colorLiteral(red: 0.7294117647, green: 0.7764705882, blue: 0.8156862745, alpha: 1),
                                       #colorLiteral(red: 0.8431372549, green: 0.9058823529, blue: 0.9176470588, alpha: 1), #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1) ,#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9098039216, alpha: 1), #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1), #colorLiteral(red: 0.7450980392, green: 0.7450980392, blue: 0.7450980392, alpha: 1),
                                       #colorLiteral(red: 0.6784313725, green: 0.6784313725, blue: 0.6784313725, alpha: 1), #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5568627451, alpha: 1), #colorLiteral(red: 0.4235294118, green: 0.4235294118, blue: 0.4235294118, alpha: 1), #colorLiteral(red: 0.3098039216, green: 0.3098039216, blue: 0.3098039216, alpha: 1), #colorLiteral(red: 0.2745098039, green: 0.2745098039, blue: 0.2745098039, alpha: 1), #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1), #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1)])
        
        return colorArray
    }
    
    
}

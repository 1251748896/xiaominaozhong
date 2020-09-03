//
//  HUD.swift
//  CustomSDK
//
//  Created by ZhongLiangLiang on 2018/1/5.
//  Copyright © 2018年 zhongliangliang. All rights reserved.
//

let FRAME = UIScreen.main.bounds
let FRAME_WIDTH = FRAME.width
let FRAME_HEIGHT = FRAME.height

import UIKit

let ViewTag = 1024

let LabelTag = 2048

public class HUD: NSObject {
    
    // MARK: 显示错误提示
    public class func showError(string: String, vc: UIViewController) {
        self.clearRepeat(string: string, imageString: "error", isIndicator: false, vc: vc)
    }
    
    // MARK: 显示成功提示
    public class func showSuccess(string: String, vc: UIViewController) {
        self.clearRepeat(string: string, imageString: "success", isIndicator: false, vc: vc)
    }
    
    // MARK: 显示提示信息
    public class func showMessage(string: String, vc: UIViewController) {
        self.clearRepeat(string: string, imageString: "", isIndicator: false, vc: vc)
    }
    
    // MARK: 显示有转圈的提示
    @objc public class func showHUD(string: String, vc: UIViewController) {
        self.clearRepeat(string: string, imageString: "", isIndicator: true, vc: vc)
    }
    
    // MARK: 隐藏有转圈的提示
    @objc public class func hiddenHUD(vc: UIViewController) {
        let view = vc.view.viewWithTag(ViewTag)
        if view != nil {
            self.disMissView(view: vc.view.viewWithTag(ViewTag)!, num: 0)
        }
    }
    
    // MARK: 清除重复的提示框、保证提示的时候只有一个提示框
    private class func clearRepeat(string: String, imageString: String, isIndicator: Bool, vc: UIViewController) {
        DispatchQueue.main.async {
            let oldView = vc.view.viewWithTag(ViewTag)
            var view = UIView.init()
            
            if oldView != nil {
                if oldView?.viewWithTag(LabelTag) != nil {
                    let oldLabel: UILabel = oldView?.viewWithTag(LabelTag) as! UILabel
                    if oldLabel.text != string {
                        oldLabel.removeFromSuperview()
                        view = self.create(string: string, imageString: imageString, isIndicator: isIndicator)
                    }
                }
            }
            else {
                view = self.create(string: string, imageString: imageString, isIndicator: isIndicator)
            }
            self.adjustPosition(vc: vc, view: view)
        }
    }
    
    // MARK: 调整位置
    private class func adjustPosition(vc: UIViewController, view: UIView) {
        var rect = view.frame
        rect.origin.x = (FRAME_WIDTH - rect.size.width) / 2
        rect.origin.y = (FRAME_HEIGHT - rect.size.height) / 2
        view.frame = rect
        vc.view.addSubview(view)
    }
    
    // MARK: 创建提示框
    private class func create(string: String, imageString: String, isIndicator: Bool) -> UIView {
        let view = self.createBackView()
        let font = UIFont.boldSystemFont(ofSize: 16)
        let size = self.wordSize(string: string, font: font, width: FRAME_WIDTH - 20)
        var width: CGFloat = 0
        var height: CGFloat = 0
        if size.width <= 60 {
            width = 90
        }
        else {
            width = size.width + CGFloat(30.0)
        }
        if isIndicator {
            height = 90
        }
        else {
            if imageString.isEmpty {
                height = size.height + CGFloat(25)
            }
            else {
                height = 90
            }
        }
        view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        //label
        let label = self.createLabel(font: font, string: string)
        if isIndicator {
            let indicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            indicator.frame = CGRect(x: Int(view.frame.size.width - 37) / 2, y: 15, width: 37, height: 37)
            let transform = CGAffineTransform.init(scaleX: 0.7, y: 0.7)
            indicator.transform = transform
            indicator.startAnimating()
            view.addSubview(indicator)
            label.frame = CGRect(x: 0, y: view.frame.size.height - size.height - 15, width: view.frame.size.width, height: size.height)
        }
        else {
            if imageString.isEmpty {
                label.frame = view.bounds
            }
            else {
                let iv = UIImageView.init()
                iv.image = UIImage.init(named: imageString)
                iv.frame = CGRect(x: (view.frame.size.width - 28) / 2, y: 15, width: 28, height: 28)
                view.addSubview(iv)
                label.frame = CGRect(x: 0, y: view.frame.size.height - size.height - 15, width: view.frame.size.width, height: size.height)
            }
        }
        view.addSubview(label)
        if !isIndicator {
            self.disMissView(view: view, num: 2)
        }
        return view
    }
    
    // MARK: 创建灰色背景图
    private class func createBackView() -> UIView {
        let view = UIView.init()
        view.tag = ViewTag
        view.backgroundColor = UIColor(red: 99.0/255.0, green: 99.0/255.0, blue: 99.0/255.0, alpha: 1.0)
        view.layer.cornerRadius = 7
        view.clipsToBounds = true
        return view
    }
    
    // MARK:  创建Label
    private class func createLabel(font: UIFont, string: String) -> UILabel {
        let label = UILabel.init()
        label.font = font
        label.text = string
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0;
        label.tag = LabelTag
        label.backgroundColor = UIColor.clear
        return label
    }
    
    // MARK: 动画隐藏view
    private class func disMissView(view: UIView, num: Int) {
        //设置演示效果
        let delay = DispatchWallTime.now() + .seconds(num)
        DispatchQueue.main.asyncAfter(wallDeadline: delay) {
            UIView.animate(withDuration: 2, animations: {
                view.alpha = 0
            }, completion: { (true) in
                view.removeFromSuperview()
            })
        }
    }
    // MARK: 计算文字所占位置打大小
    private class func wordSize(string: String , font: UIFont, width: CGFloat) -> CGSize {
        let size: CGSize = CGSize.init(width: width, height: 200.0)
        let attributes = [NSAttributedStringKey.font: font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect:CGRect = string.boundingRect(with: size, options: option, attributes: attributes, context: nil)
        return rect.size
    }
}


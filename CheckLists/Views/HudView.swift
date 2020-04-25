//
//  HudView.swift
//  MyLocations
//
//  Created by Wilfred Asomani on 14/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation
import UIKit

class HudView: UIView {
    var text = "Done!"
    var image = "Checkmark"
    var state = DataState.success(nil)
    
    class func hud(inView view: UIView, animated: Bool, state: DataState = DataState.success(nil)) -> HudView {
        let hud = HudView(frame: view.bounds)
        hud.isOpaque = false
        
        view.addSubview(hud)
        
        let generator = UINotificationFeedbackGenerator()
        hud.state = state
        switch state {
        case .success(_):
            hud.text = "Done!"
            hud.image = "Checkmark"
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            generator.notificationOccurred(.success)
        case .loading:
            hud.text = "Loading"
            hud.image = "mat_loading"
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        default:
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            hud.text = "Ooops"
            hud.image = "mat_close"
            generator.notificationOccurred(.error)
        }
        
        hud.show(animated: animated)
        return hud
    }
    
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 100
        let boxHeight = boxWidth
        
        // always round size values for drawing cos fractional pixel boundaries might be fuzzy
        let boxRect = CGRect(
            x: round((rect.width - boxWidth) / 2),
            y: round((rect.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight)
        let roundRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        getFillColor().setFill()
        roundRect.fill()
        
        if let image = getImage() {
            let imagePoint = CGPoint(
                x: center.x - (image.size.width / 2),
                y: center.y - (image.size.height / 2) - (boxHeight / 8))
            image.draw(at: imagePoint)
        }
        
        let textSize = text.size(withAttributes: getTextAttributes())
        let textPoint = CGPoint(
            x: center.x - (textSize.width / 2),
            y: center.y - (textSize.height / 2) + (boxHeight / 4))
        text.draw(at: textPoint, withAttributes: getTextAttributes())
    }
    
    // MARK:- private
    
    private func getImage() -> UIImage? {
        if let image = UIImage(named: image) {
            if #available(iOS 13.0, *) {
                return image.withTintColor(.label)
            } else {
                return image
            }
        }
        return nil
    }
    
    private func getTextAttributes() -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.white
        ]
        if #available(iOS 13.0, *) {
            attributes.updateValue(UIColor.label, forKey: NSAttributedString.Key.foregroundColor)
        }
        return attributes
    }
    
    private func getFillColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.groupTableViewBackground.withAlphaComponent(0.9)
        } else {
            return UIColor(white: 0.3, alpha: 0.9)
        }
    }
    
    // MARK:- public
    
    func show(animated: Bool) {
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
    
    func hide() {
        superview?.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.4) {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.removeFromSuperview()
        }
    }
}

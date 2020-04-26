//
//  HudView.swift
//  MyLocations
//
//  Created by Wilfred Asomani on 14/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation
import UIKit
import JGProgressHUD

class HudView {
    class func showIndicator(for state: DataState, in view: UIView) -> JGProgressHUD? {
        let style: JGProgressHUDStyle
        if view.traitCollection.userInterfaceStyle == .dark {
            style = .dark
        } else {
            style = .light
        }
        let hud = JGProgressHUD(style: style)
        let generator = UINotificationFeedbackGenerator()
        let feedbackType: UINotificationFeedbackGenerator.FeedbackType?
        switch state {
        case .loading:
            hud.textLabel.text = "Loading"
            feedbackType = nil
        case .success(_):
            hud.textLabel.text = "Done!"
            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            hud.dismiss(afterDelay: 0.7)
            feedbackType = .success
        default:
            hud.textLabel.text = "Ooops!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.dismiss(afterDelay: 0.7)
            feedbackType = .error
        }
        if let feedbackType = feedbackType {
            generator.notificationOccurred(feedbackType)
        }
        hud.animation = JGProgressHUDFadeZoomAnimation()
        hud.show(in: view)
        
        return hud
    }
}


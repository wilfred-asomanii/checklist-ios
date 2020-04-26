//
//  AuthViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 19/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import FirebaseUI

class AuthViewController: UIViewController {
    
    @IBOutlet weak var logInButton: UIButton!
    
    var authController: AuthController!
    var fireAuthController: UINavigationController?
    var hud: JGProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setToolbarHidden(true, animated: true)
        navigationController?.navigationBar.isHidden = true
        
        logInButton.layer.cornerRadius = 10
        
        let authUI = FUIAuth.defaultAuthUI()!
        authUI.delegate = self
        authUI.providers = [
            FUIEmailAuth(),
            FUIGoogleAuth()
        ]
        authUI.shouldHideCancelButton = true
        fireAuthController = authUI.authViewController()
        fireAuthController?.navigationBar.tintColor = .systemPurple
        fireAuthController?.title = "Choose Auth Method"
        
        guard let user = authController.currentUser else {
            return
        }
        navigateToMain(for: user)
    }
    
    func navigateToMain(for user: User) {
        if let tab = storyboard?.instantiateViewController(withIdentifier: "tabController") as? UITabBarController,
            let controller = tab.viewControllers?.first as? UINavigationController,
            let mainTab = controller.viewControllers.first as? AllListsViewController,
            let lastTab = tab.viewControllers?.last as? ProfileViewController {
            
            let dataController = DataController()
            mainTab.dataController = dataController
            
            lastTab.auth = authController
            lastTab.dataController = dataController
            navigationController?.pushViewController(tab, animated: true)
        }
    }
    
    func authComplete(_ result: AuthDataResult?, _ error: Error?) {
        hud?.dismiss()
        guard error == nil else {
            if let err = error as NSError?, err.code != FUIAuthErrorCode.userCancelledSignIn.rawValue {
                hud = HudView.showIndicator(for: .error(error), in: view)
            }
            return
        }
        hud = HudView.showIndicator(for: .success(nil), in: view)
        self.navigateToMain(for: result!.user)
    }
    
    @IBAction func logIn(_ sender: Any) {
        present(fireAuthController!, animated: true, completion: nil)
    }
}

// MARK:- firebase auth ui delegates
extension AuthViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        fireAuthController?.dismiss(animated: true) {
            self.fireAuthController?.popToRootViewController(animated: false)
        }
        authComplete(authDataResult, error)
    }
}

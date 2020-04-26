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

class AuthViewController: UIViewController {
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var authController: AuthController!
    var hud: JGProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setToolbarHidden(true, animated: true)
        if #available(iOS 13, *) {
            visualEffectView.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        }
        
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
            dismiss(animated: true, completion: nil)
        }
    }
    
    func authComplete(_ result: AuthDataResult?, _ error: Error?) {
        hud?.dismiss()
        guard error == nil else {
                        hud = HudView.showIndicator(for: .error(error), in: view)
            return
        }
        hud = HudView.showIndicator(for: .success(nil), in: view)
        self.navigateToMain(for: result!.user)
    }
    
    @IBAction func logIn(_ sender: Any) {
        hud = HudView.showIndicator(for: .loading, in: view)
        authController.signIn(withEmail: emailField.text!, password: passwordField.text!) {
            [weak self] result, err in
            self?.authComplete(result, err)
        }
    }
    @IBAction func enterPressed(_ sender: UITextField) {
        if sender == emailField {
            emailField.resignFirstResponder()
            passwordField.becomeFirstResponder()
            return
        }
        if sender == passwordField {
            passwordField.resignFirstResponder()
            logIn(sender)
        }
    }
}

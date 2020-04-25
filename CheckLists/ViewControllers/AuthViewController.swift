//
//  AuthViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 19/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthViewController: UIViewController {
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var authController: AuthController!
    
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
            
            let dataModel = DataModel()
            mainTab.dataModel = dataModel
            
            lastTab.auth = authController
            lastTab.dataModel = dataModel
            navigationController?.pushViewController(tab, animated: true)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func authComplete(_ result: AuthDataResult?, _ error: Error?) {
        guard error == nil else {
            let alert = UIAlertController(title: "Oops", message: "Could not sign you in", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        self.navigateToMain(for: result!.user)
    }
    
    @IBAction func logIn(_ sender: Any) {
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

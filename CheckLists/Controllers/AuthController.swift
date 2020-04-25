//
//  AuthController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 24/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation
import FirebaseAuth

class AuthController {
    private var auth: Auth {
        Auth.auth()
    }
    
    var currentUser: User? {
        auth.currentUser
    }
    
    func createUser(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        auth.createUser(withEmail: email, password: password, completion: completion)
    }
    
    func signIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        auth.signIn(withEmail: email, password: password, completion: completion)
    }
    
    func logOut() -> Bool {
        do {
            try auth.signOut()
            return true
        } catch {
            return false
        }
    }
    
}

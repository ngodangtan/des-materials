//
//  LoginViewController.swift
//
//
//  Created by Tan Ngo Dang on 20/9/25.
//

import UIKit

// MARK: - Object Using an Adapter
// 1
public class LoginViewController: UIViewController {
    // MARK: - Properties
    public var authService: AuthenticationService!
    // MARK: - Views
    public var emailTextField = UITextField()
    public var passwordTextField = UITextField()
    
    // MARK: - Class Constructors
    // 2
    public class func instance(
        with authService: AuthenticationService)
    -> LoginViewController {
        let viewController = LoginViewController()
        viewController.authService = authService
        return viewController
    }

    // 3
    public func login() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
            print("Email and password are required inputs!")
            return
        }
        authService.login(
            email: email,
            password: password,
            success: { user, token in
                print("Auth succeeded: \(user.email), \(token.value)")
            },
            failure: { error in
                print("Auth failed with error: no error provided")
            }
        )
    }
}

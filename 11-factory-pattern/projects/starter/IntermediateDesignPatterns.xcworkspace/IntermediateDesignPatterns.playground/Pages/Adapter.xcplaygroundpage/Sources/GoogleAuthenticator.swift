//
//  GoogleAuthenticator.swift
//  
//
//  Created by Tan Ngo Dang on 20/9/25.
//

import UIKit
// MARK: - Legacy Object
public class GoogleAuthenticator {
    public func login(
        email: String,
        password: String,
        completion: @escaping (GoogleUser?, Error?) -> Void) {
            // Make networking calls that return a token string
            let token = "special-token-value"
            let user = GoogleUser(email: email,
                                  password: password,
                                  token: token)
            completion(user, nil)
        }
}
public struct GoogleUser {
    public var email: String
    public var password: String
    public var token: String
}

/*
 Imagine GoogleAuthenticator is a third-party class that cannot be modified.
 Thereby, it is the legacy object. Of course, the actual Google authenticator would be
 a lot more complex; we’ve just named this one “Google” as an example and faked the
 networking call.
 */

//
//  GoogleAuthenticatorAdapter.swift
//  
//
//  Created by Tan Ngo Dang on 20/9/25.
//

public class GoogleAuthenticatorAdapter: AuthenticationService {
    private let authenticator = GoogleAuthenticator()
    public init() {}
    public func login(email: String, password: String, success: @escaping (User, Token) -> Void, failure: @escaping (any Error) -> Void) {
        authenticator.login(email: email, password: password) { googleUser, error in
            guard let googleUser = googleUser else {
                if let error {
                    failure(error)
                }
                return
            }
            
            let user = User(email: googleUser.email, password: googleUser.password)
            let token = Token(value: googleUser.token)
            success(user,token)
        }
    }
}

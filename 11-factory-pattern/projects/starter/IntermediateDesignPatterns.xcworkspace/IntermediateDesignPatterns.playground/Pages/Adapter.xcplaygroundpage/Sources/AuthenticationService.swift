//
//  AuthenticationService.swift
//  
//
//  Created by Tan Ngo Dang on 20/9/25.
//

public protocol AuthenticationService {
    func login(email: String,
               password: String,
               success: @escaping(User, Token) -> Void,
               failure: @escaping (Error) -> Void)
}

public struct User {
    public let email: String
    public let password: String
}

public struct Token {
    public let value: String
}

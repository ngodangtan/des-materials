//
//  Model.swift
//  
//
//  Created by Tan Ngo Dang on 20/9/25.
//

public struct JobApplicant {
    public var name: String
    public var email: String
    public var status: Status
    
    public init(name: String, email: String, status: Status) {
        self.name = name
        self.email = email
        self.status = status
    }
    
    public enum Status {
        case new
        case interview
        case hired
        case rejected
    }
}

public struct Email {
    public let subject: String
    public let messageBody: String
    public let recipientEmail: String
    public let senderEmail: String
    
    public init(subject: String, messageBody: String, recipientEmail: String, senderEmail: String) {
        self.subject = subject
        self.messageBody = messageBody
        self.recipientEmail = recipientEmail
        self.senderEmail = senderEmail
    }
}

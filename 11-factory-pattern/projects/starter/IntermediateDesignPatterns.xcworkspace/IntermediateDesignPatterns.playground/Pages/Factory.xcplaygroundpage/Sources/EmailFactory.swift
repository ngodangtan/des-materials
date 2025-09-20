//
//  EmailFactory.swift
//
//
//  Created by Tan Ngo Dang on 20/9/25.
//

// Logic ở đây là tạo ra email gửi cho ứng viên tương ứng với status hiện tại
public struct EmailFactory {
    // 2
    public let senderEmail: String
    
    public init(senderEmail: String) {
        self.senderEmail = senderEmail
    }  
    // 3
    public func createEmail(to recipient: JobApplicant) -> Email {
        let subject: String
        let messageBody: String
        switch recipient.status {
        case .new:
            subject = "We Received Your Application"
            messageBody =
            "Thanks for applying for a job here! " +
            "You should hear from us in 17-42 business days."
        case .interview:
            subject = "We Want to Interview You"
            messageBody =
            "Thanks for your resume, \(recipient.name)! " +
            "Can you come in for an interview in 30 minutes?"
        case .hired:
            subject = "We Want to Hire You"
            messageBody =
            "Congratulations, \(recipient.name)! " +
            "We liked your code, and you smelled nice. " +
            "We want to offer you a position! Cha-ching! $$$"
        case .rejected:
            subject = "Thanks for Your Application"
            messageBody =
            "Thank you for applying, \(recipient.name)! " +
            "We have decided to move forward " +
            "with other candidates. " +
            "Please remember to wear pants next time!"
        }
        return Email(subject: subject,
                     messageBody: messageBody,
                     recipientEmail: recipient.email,
                     senderEmail: senderEmail)
    }
}

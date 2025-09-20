/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Factory
 - - - - - - - - - -
 ![Factory Diagram](Factory_Diagram.png)
 
 The factory pattern provides a way to create objects without exposing creation logic. It involves two types:
 
 1. The **factory** creates objects.
 2. The **products** are the objects that are created.
 
 ## Code Example
 */

var jackson = JobApplicant(name: "Jackson Smith",
                           email: "jackson.smith@example.com",
                           status: .new)
let emailFactory = EmailFactory(senderEmail: "RaysMinions@RaysCoffeeCo.com")
// New
// send email
print(emailFactory.createEmail(to: jackson), "\n")
// Interview
jackson.status = .interview
// send email
print(emailFactory.createEmail(to: jackson), "\n")
// Hired
jackson.status = .hired
// send email
print(emailFactory.createEmail(to: jackson), "\n")

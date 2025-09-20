/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Adapter
 - - - - - - - - - -
 ![Adapter Diagram](Adapter_Diagram.png)
 
 The adapter pattern allows incompatible types to work together. It involves four components:
 
 1. An **object using an adapter** is the object that depends on the new protocol.
 
 2. The **new protocol** that is desired to be used.
 
 3. A **legacy object** that existed before the protocol was made and cannot be modified directly to conform to it.
 
 4. An **adapter** that's created to conform to the protocol and passes calls onto the legacy object.
 
 ## Code Example
 */
/*
 When should you use it?
 Classes, modules, and functions can’t always be modified, especially if they’re from a
 third-party library. Sometimes you have to adapt instead!
 You can create an adapter either by extending an existing class, or creating a new
 adapter class. This chapter will show you how to do both.
 */

import UIKit

// MARK: - Example
let viewController = LoginViewController.instance(with: GoogleAuthenticatorAdapter())
viewController.emailTextField.text = "user@example.com"
viewController.passwordTextField.text = "password"
viewController.login()

/*
 The adapter pattern allows you to conform to a new protocol without changing an
 underlying type. This has the consequence of protecting against future changes
 against the underlying type, but it also makes your implementation harder to read
 and maintain.
 Be careful about implementing the adapter pattern unless you recognize there's a
 real possibility for change. If there isn't, consider if it makes sense to use the
 underlying type directly.
 */

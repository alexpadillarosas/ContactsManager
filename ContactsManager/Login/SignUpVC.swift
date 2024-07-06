//
//  SignUpVC.swift
//  ContactsManager
//
//  Created by alex on 3/5/2024.
//

import UIKit
import FirebaseAuth


class SignUpVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var logInActivityIndicatorView: UIActivityIndicatorView!
    
    let service = ContactRespository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpDidPress(_ sender: Any) {
        
        guard !emailTextField.text.isBlank else{
            showAlertMessage(title: "Validation", message: "Email is mandatory")
            return
        }
        guard emailTextField.text.isValidEmail else{
            showAlertMessage(title: "Validation", message: "Invalid Email format")
            return
        }
        guard !passwordTextField.text.isBlank else{
            showAlertMessage(title: "Validation", message: "Password is mandatory")
            return
        }
        guard !passwordConfirmationTextField.text.isBlank else{
            showAlertMessage(title: "Validation", message: "Confirm Password is mandatory")
            return
        }
        
        guard   let email = emailTextField.text,
                let password = passwordTextField.text ,
                let confirmation = passwordConfirmationTextField.text, password == confirmation else {
            showAlertMessage(title: "Validation", message: "Password and Password Confirmation do not match")
            return
        }
        logInActivityIndicatorView.startAnimating()
        
        // Create a closure with code to execute as soon as the user acknowledge the confirmation email message
        let registerUserClosure : () -> Void = {
            //Get the UserId
            let userAuthId = Auth.auth().currentUser?.uid
            print("signed up id \(userAuthId ?? "NIL")")
            //create an object user so we can save it in cloud firestore inside of the users collection
            let user = User(id: userAuthId!,
                            firstname: "",
                            lastname: "",
                            email: email,
                            phone: "",
                            photo: ""
//                            registered: ,//We can ommit it, as it's declared as param with default value nil
//                            contacts: []  //the user has not contacts registered at this point
                            )
            
            if self.service.addUser(user: user) {
                print("User Added \(user.email)")
            }
            
            // programmatically navigate to LoginVC so the user will Log in after confirming their account
            // The commented code below it's an option but since we need to go to the previous view controller
            // and SignUpVC is connected to the same navigation controller, we can just use it to go back to
            // the previous view controller
            
            /*
            let loginViewController = self.storyboard?.instantiateViewController(identifier: "LoginVC") as? UINavigationController
            
            self.view.window?.rootViewController = loginViewController
            self.view.window?.makeKeyAndVisible()
             */
            self.navigationController?.popViewController(animated: true)
            
        }
        
        
        /*
         This function createUser receives as last parameter a closure:
         Since the last parameter is a closure we can call it trailing closure therefore, we can place the closure outside
         the function's parentheses. after the open and close curly braces.
         This function as seen in the source code, receives a result and an error
         */
        Auth.auth().createUser(withEmail: email, password: password){ authResult, error in
            guard error == nil else {
                self.showAlertMessage(title: "We could not create the account", message: "\(error!.localizedDescription)")
                self.logInActivityIndicatorView.stopAnimating()
                return
            }
//            self.showAlertMessage(title: "yay", message: "user registered, UID: \(authResult!.user.uid)")
            
            /**
             This function send an email to the user, to confirm the account
             */
            Auth.auth().currentUser?.sendEmailVerification{ error in
                if let error = error {
                    self.showAlertMessage(title: "Error", message: "\(error)")
                    self.logInActivityIndicatorView.stopAnimating()
                    return
                }

                
                self.logInActivityIndicatorView.stopAnimating()
                self.showAlertMessageWithHandler(title: "Email Confirmation Sent", 
                                                 message: "A confirmation email has been sent to you email account, please confirm your account before you log in",
                                                 onComplete: registerUserClosure)
              }
             
        }
    
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

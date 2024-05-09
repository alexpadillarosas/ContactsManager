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
        /*
         This function createUser receives as last parameter a closure:
         Since the last parameter is a closure we can call it trailing closure therefore, we can place the closure outside
         the function's parentheses. after the open and close curly braces.
         This function as seen in the source code, receives a result and an error
         */
        Auth.auth().createUser(withEmail: email, password: password){ authResult, error in
            guard error == nil else {
                self.showAlertMessage(title: "Error", message: "Failed to create a new account")
                print(error!)
                self.logInActivityIndicatorView.stopAnimating()
                return
            }
            self.logInActivityIndicatorView.stopAnimating()
            self.showAlertMessage(title: "yay", message: "user registered, UID: \(authResult!.user.uid)")
            
        }
    
    }
    
    //we created this function temporarily, we will replace it for isBlank in the Extensions.swift file
    func isBlank (optionalString :String?) -> Bool {
        
        guard let myString = optionalString, !myString.trimmingCharacters(in:.whitespaces).isEmpty else {
            print("String is nil or empty.")
            return false // or break, continue, throw
        }
        return true
//        if let string = optionalString {
//            return string.isEmpty
//        } else {
//            return true
//        }
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

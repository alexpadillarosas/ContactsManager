//
//  LogInVC.swift
//  ContactsManager
//
//  Created by alex on 3/5/2024.
//

import UIKit
import FirebaseAuth

class LogInVC: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInActivityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    

    @IBAction func loginDidPress(_ sender: Any) {
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
        //we use an implicitly unwrapped optional (!) because at this point in the code we are sure emailTextField.text and passwordTextField.text have values (check guards above)
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        logInActivityIndicatorView.startAnimating()
        //Since the last parameter is a closure we can call it trailing closure
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard error == nil else {
                self?.showAlertMessage(title: "Error", message: "Failed to Log In")
                print(error!)
                self?.logInActivityIndicatorView.stopAnimating()
                return
            }
            self?.logInActivityIndicatorView.stopAnimating()
          // TODO: Navigate to the App first Scene
            self?.showAlertMessage(title: "Success", message: "Logged In")
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }x
    */

}

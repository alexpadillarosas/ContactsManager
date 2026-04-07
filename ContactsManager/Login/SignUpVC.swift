import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var logInActivityIndicatorView: UIActivityIndicatorView!
    
    let service = Repository.sharedRepository
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @IBAction func signUpDidPress(_ sender: Any) {
        // Validate Form, also unwrapp email and password
        guard validateInputs(),
              let email = emailTextField.text,
              let password = passwordTextField.text else {
            return
        }
        
        logInActivityIndicatorView.startAnimating()
        
        // Start Async Signup Flow
        Task {
            do {
                // A. Create User in Firebase Auth
                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                let uid = authResult.user.uid
                
                // B. Send Verification Email
                try await authResult.user.sendEmailVerification()
                
                // C. Save User Profile to Firestore
                // Teaching Tip: Use the real UID from Auth, not the email, as the document ID
                let newUser = User(id: uid, firstname: "", lastname: "", email: email, phone: "", photo: "")
                try await service.addUser(withData: newUser)
                
                // D. Success! Inform user and navigate back
                logInActivityIndicatorView.stopAnimating()
                
                showAlertMessageWithHandler(
                    title: "Account Created",
                    message: "Please check your email to verify your account before logging in.",
                    onComplete: {
                        self.navigationController?.popViewController(animated: true)
                    }
                )
                
            } catch {
                logInActivityIndicatorView.stopAnimating()
                showAlertMessage(title: "Signup Error", message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Helper Logic
    
    private func validateInputs() -> Bool {
        // Teach students: 'guard' makes validation very readable
        guard let email = emailTextField.text, !email.isBlank, emailTextField.text.isValidEmail else {
            showAlertMessage(title: "Validation", message: "A valid email is mandatory")
            return false
        }
        
        guard let pass = passwordTextField.text, !pass.isBlank,
              let confirm = passwordConfirmationTextField.text, pass == confirm else {
            showAlertMessage(title: "Validation", message: "Passwords are empty or do not match")
            return false
        }
        
        return true
    }
}


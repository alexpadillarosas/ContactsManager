import UIKit
import FirebaseAuth

class LogInVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInActivityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Teach students: using system icons makes the app look native
        emailTextField.setLeftView(image: UIImage(systemName: "envelope")!)
        passwordTextField.setLeftView(image: UIImage(systemName: "lock")!)
        
        // Ensure the indicator is hidden when not animating
        logInActivityIndicatorView.hidesWhenStopped = true
    }
    
    // MARK: - Actions
    
    @IBAction func loginDidPress(_ sender: Any) {
        // 1. Validate inputs using Guard (Exit early if data is missing)
        guard let email = emailTextField.text, !email.isBlank else {
            showAlertMessage(title: "Validation", message: "Email is mandatory")
            return
        }
        
        guard emailTextField.text.isValidEmail else {
            showAlertMessage(title: "Validation", message: "Please enter a valid email format")
            return
        }
        
        guard let password = passwordTextField.text, !password.isBlank else {
            showAlertMessage(title: "Validation", message: "Password is mandatory")
            return
        }
        
        // 2. Start Loading
        logInActivityIndicatorView.startAnimating()
        
        // 3. Perform Login using Swift Concurrency (Async/Await)
        Task {
            do {
                // Try to sign in
                try await Auth.auth().signIn(withEmail: email, password: password)
                
                // Check if the user is verified
                guard let authUser = Auth.auth().currentUser, authUser.isEmailVerified else {
                    logInActivityIndicatorView.stopAnimating()
                    showAlertMessage(title: "Verification Pending", message: "Please verify your email before logging in.")
                    return
                }
                
                // 4. Success -> Go to Home
                logInActivityIndicatorView.stopAnimating()
                navigateToHome()
                
            } catch {
                // Handle Firebase Errors (e.g. wrong password, no internet)
                logInActivityIndicatorView.stopAnimating()
                showAlertMessage(title: "Login Failed", message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func forgottenPasswordDidPress(_ sender: Any) {
        guard let email = emailTextField.text, !email.isBlank else {
            showAlertMessage(title: "Email Required", message: "Please enter your email to reset your password.")
            return
        }
        
        logInActivityIndicatorView.startAnimating()
        
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: email)
                logInActivityIndicatorView.stopAnimating()
                showAlertMessage(title: "Success", message: "Password reset email sent!")
            } catch {
                logInActivityIndicatorView.stopAnimating()
                showAlertMessage(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Navigation Helper
    
    private func navigateToHome() {
        // Teaching tip: Switching the rootViewController is the cleanest way to move from Login to the Main App.
        // It prevents the user from clicking 'Back' to return to the Login screen.
        if let homeVC = storyboard?.instantiateViewController(identifier: "HomeVC") as? UITabBarController {
            view.window?.rootViewController = homeVC
            view.window?.makeKeyAndVisible()
        }
    }
}


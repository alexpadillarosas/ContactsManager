import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileTVC: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var dobDatePicker: UIDatePicker!
    @IBOutlet weak var registerAtDatePicker: UIDatePicker!
    @IBOutlet weak var fullnameLabel: UILabel!
    
    // MARK: - Properties
    let service = Repository.sharedRepository
    var user: User? // Use optional to handle the "loading" state:
    var originalUser : User? // used to detect changes
    
    var mandatoryFields = [UITextField]()
    /**
     When the ProfileTVC first loads, the screen appears, but Firebase hasn't responded yet. By making the user optional, you prevent the app from crashing.
     Notice: "If user is nil, we are still waiting for the internet. Don't let the user click 'Save' yet!"
     The Code: saveBarButtonItem.isEnabled = false (Because the data is still nil).
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mandatoryFields = [firstnameTextField, lastnameTextField, phoneTextField]
        loadUserProfile()
    
    }
    
    // MARK: - Logic
    
    private func loadUserProfile() {
        guard let userId = Auth.auth().currentUser?.email else {
            return
        }
        
        Task {
            do {
                // Fetch user data using our async service
                if let returnedUser = try await service.findUserInfo(for: userId) {
                    //Here the data is back from the DB
                    self.user = returnedUser
                    self.originalUser = returnedUser // the copy to validate if there were changes
                    self.setupUI(with: returnedUser)

                }
            } catch {
                print("Error loading profile: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupUI(with user: User) {
        firstnameTextField.text = user.firstname
        lastnameTextField.text = user.lastname
        phoneTextField.text = user.phone
        emailLabel.text = user.email
        
        // Convert Firestore Timestamps to Swift Dates for the DatePickers
        dobDatePicker.setDate(user.dob.dateValue(), animated: true)
        registerAtDatePicker.setDate(user.registered.dateValue(), animated: true)
    }
    

    // MARK: - Actions
    
    @IBAction func saveButtonDidPress(_ sender: Any) {

        guard isFormValid(mandatoryFieldsArray: mandatoryFields) else {
            showInvalidTextFields(mandatoryFieldsArray: mandatoryFields)
            showAlertMessage(title: "validation", message: "Please fill in all mandatory fields")
            return
        }
        
        guard let currentUser = self.user, let original = self.originalUser,
                currentUser.firstname != original.firstname ||
                currentUser.lastname != original.lastname ||
                currentUser.phone != original.phone ||
                currentUser.dob.dateValue() != original.dob.dateValue() else{
            showAlertMessage(title: "Info", message: "No changes detected to save")
            return
        }
        // if you wonder why is a constant but I could change its properties, it is becasue the class itself does not change
        // what it changes are its properties.
        // Update our local object with the new UI values
        currentUser.firstname = firstnameTextField.text!
        currentUser.lastname = lastnameTextField.text!
        currentUser.phone = phoneTextField.text!
        currentUser.dob = Timestamp(date: dobDatePicker.date)
        
        Task {
            do {
                try await service.updateUser(withData: currentUser)
                //refresh the name next to the image, in case it has changed, at this point I know both have data
                self.fullnameLabel.text = firstnameTextField.text! + " " + lastnameTextField.text!
                //reset baseline after saving
                self.originalUser = currentUser

                showAlertMessage(title: "Success", message: "Profile Updated!")
            } catch {
                showAlertMessage(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func cancelButtonDidPress(_ sender: Any) {
        
        guard let original = originalUser else {
            return
        }
        
        // Restore original values
        setupUI(with: original)
        
        // Remove validation UI (borders/icons)
        let fields = [firstnameTextField, lastnameTextField, phoneTextField]
        
        for field in fields {
            field?.removeInvalidBorder()
            field?.hideErrorIcon()
        }
        //dismiss the keyboard
        view.endEditing(true)
    }

    @IBAction func logoutButtonDidPress(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
            // When logging out, replace the root view controller
            // so the user cannot click "Back" to see the profile.
            if let loginNav = storyboard?.instantiateViewController(identifier: "LoginVC") as? UINavigationController {
                view.window?.rootViewController = loginNav
                view.window?.makeKeyAndVisible()
            }
        } catch {
            print("Error signing out")
        }
    }
    
    @IBAction func changePasswordButtonDidPress(_ sender: Any) {
        let alertCtrler = UIAlertController(
            title: "Change Password",
            message: "Enter your current password and new password",
            preferredStyle: .alert
        )
        
        // Current password field
        alertCtrler.addTextField { $0.placeholder = "Current Password"; $0.isSecureTextEntry = true }
        
        // New password field
        alertCtrler.addTextField { $0.placeholder = "New Password"; $0.isSecureTextEntry = true }
        
        // Cancel action
        alertCtrler.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        let changeAction = UIAlertAction(title: "Change", style: UIAlertAction.Style.default) { myAction in
            self.handleChangePassword(action: myAction, alert: alertCtrler)
        }
            
        alertCtrler.addAction(changeAction)
        
        present(alertCtrler, animated: true)
    }
    
    private func handleChangePassword(action: UIAlertAction, alert: UIAlertController) {
        // Ensure text fields are not empty
        guard let currentPassword = alert.textFields?[0].text,
              let newPassword = alert.textFields?[1].text,
              !currentPassword.isBlank,
              !newPassword.isBlank else {
            showAlertMessage(title: "Error", message: "Please fill in both fields.")
            return
        }
        
        // Call the Firebase re-authentication & password update
        reauthenticateAndChangePassword(currentPassword: currentPassword, newPassword: newPassword)
    }
    
    
    private func reauthenticateAndChangePassword(currentPassword: String, newPassword: String) {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            showAlertMessage(title: "Error", message: "User not logged in.")
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        
        // Re-authenticate first
        user.reauthenticate(with: credential) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlertMessage(title: "Error", message: "Re-authentication failed: \(error.localizedDescription)")
                return
            }
            
            // Re-authentication successful → update password
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    self.showAlertMessage(title: "Error", message: "Password change failed: \(error.localizedDescription)")
                } else {
                    self.showAlertMessage(title: "Success", message: "Password successfully changed!")
                }
            }
        }
    }
    
    
    
}


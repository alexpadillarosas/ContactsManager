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
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
    // MARK: - Properties
    let service = Repository.sharedRepository
    var user: User? // Use optional to handle the "loading" state:
    /**
     When the ProfileTVC first loads, the screen appears, but Firebase hasn't responded yet. By making the user optional, you prevent the app from crashing.
     Notice: "If user is nil, we are still waiting for the internet. Don't let the user click 'Save' yet!"
     The Code: saveBarButtonItem.isEnabled = false (Because the data is still nil).
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserProfile()
    }
    
    // MARK: - Logic
    
    private func loadUserProfile() {
        // Teach students: Always use UID for database lookups
        guard let userId = Auth.auth().currentUser?.email else { return }
        
        saveBarButtonItem.isEnabled = false // Disable save until data is loaded
        
        Task {
            do {
                // Fetch user data using our async service
                if let returnedUser = try await service.findUserInfo(for: userId) {
                    //Here the data is back from the DB
                    self.user = returnedUser
                    self.setupUI(with: returnedUser)
                    self.saveBarButtonItem.isEnabled = true
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
    
    private func isDataValid() -> Bool {
        // Teach students: Guard statements make validation much cleaner than if-else
        guard let first = firstnameTextField.text, !first.isBlank,
              let last = lastnameTextField.text, !last.isBlank else {
            
            // Highlight fields that are empty
            firstnameTextField.text.isBlank ? firstnameTextField.showInvalidBorder() : firstnameTextField.removeInvalidBorder()
            lastnameTextField.text.isBlank ? lastnameTextField.showInvalidBorder() : lastnameTextField.removeInvalidBorder()
            
            showAlertMessage(title: "Validation", message: "First and Last name are mandatory.")
            return false
        }
        return true
    }

    // MARK: - Actions
    
    @IBAction func saveButtonDidPress(_ sender: Any) {
        guard isDataValid(), let currentUser = self.user else {
            return
        }
        
        // Update our local object with the new UI values
        currentUser.firstname = firstnameTextField.text!
        currentUser.lastname = lastnameTextField.text!
        currentUser.phone = phoneTextField.text!
        currentUser.dob = Timestamp(date: dobDatePicker.date)
        
        Task {
            do {
                try await service.updateUser(withData: currentUser)
                showAlertMessage(title: "Success", message: "Profile Updated!")
            } catch {
                showAlertMessage(title: "Error", message: error.localizedDescription)
            }
        }
    }

    @IBAction func logoutButtonDidPress(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
            // Teaching Tip: When logging out, replace the root view controller
            // so the user cannot click "Back" to see the profile.
            if let loginNav = storyboard?.instantiateViewController(identifier: "LoginVC") as? UINavigationController {
                view.window?.rootViewController = loginNav
                view.window?.makeKeyAndVisible()
            }
        } catch {
            print("Error signing out")
        }
    }
}


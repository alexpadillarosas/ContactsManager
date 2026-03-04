
import UIKit
import FirebaseFirestore
import FirebaseAuth

class AddContactTVC: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var favouriteSwitch: UISwitch!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var photoTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Actions
    
    /// This is the main "Save" logic.
    /// Note: Connect this to a Bar Button Item or a Button in your Storyboard.
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        // 1. Validate the UI
        guard isFormValid() else {
            showInvalidTextFields()
            return
        }
        
        // 2. Extract data and create the Contact object
        // We use nil-coalescing (?? "") to avoid crashes from empty fields
        let contact = Contact(
            firstname: firstnameTextField.text ?? "",
            lastname: lastnameTextField.text ?? "",
            email: emailTextField.text ?? "",
            phone: phoneTextField.text ?? "",
            photo: photoTextField.text ?? "",
            note: notesTextField.text ?? "",
            favourite: favouriteSwitch.isOn,
            registered: Timestamp(date: Date()),
            tags: []
        )
        
        // 3. Save to Firebase
        saveContact(contact)
    }

    // MARK: - Logic Methods
    
    private func saveContact(_ contact: Contact) {
        // Use the permanent UID (User ID) instead of Email for the database key
        guard let userId = Auth.auth().currentUser?.email else { return }
        
        let service = Repository.sharedRepository
        
        Task {
            do {
                try await service.addContact(for: userId, withData: contact)
                print("✅ Contact saved successfully")
                
                // 4. Navigate back only after the save is successful
                self.navigationController?.popViewController(animated: true)
            } catch {
                print("❌ Error saving: \(error.localizedDescription)")
                // Optional: Show an alert to the student/user here
            }
        }
    }

    /// Checks if mandatory fields are filled.
    /// Teaching tip: Using a list/array makes it easy to add more fields later.
    private func isFormValid() -> Bool {
        let mandatoryFields = [firstnameTextField, lastnameTextField, emailTextField, phoneTextField]
        
        // If any field is blank, the form is invalid
        for field in mandatoryFields {
            if field?.text?.isBlank ?? true {
                return false
            }
        }
        return true
    }

    /// Updates the UI borders to provide visual feedback to the student.
    private func showInvalidTextFields() {
        let fields = [firstnameTextField, lastnameTextField, emailTextField, phoneTextField]
        
        for field in fields {
            if let textField = field {
                textField.text.isBlank ? textField.showInvalidBorder() : textField.removeInvalidBorder()
            }
        }
    }
}

import UIKit
import FirebaseAuth
import FirebaseFirestore

/**
 Create an Unwind segue but from the Instead, Control-drag from  the View Controller itself at the top of the scene (the Yellow Circle icon) to the Exit icon.
 This is a unwind segue we will trigger manually.
 Select the segue and then give it an identifier: unwindAfterEditSave, then when tapping the save button, trigger the unwind segue
 */
class EditContactTVC: UITableViewController {
    
    // The contact to be edited, passed from the previous screen
    var contact: Contact!
    
    // MARK: - Outlets
    @IBOutlet weak var favouriteSwitch: UISwitch!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!

    var textFieldsToValidate = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        textFieldsToValidate = [firstnameTextField, lastnameTextField, emailTextField, phoneTextField]
    }
    
    private func setupUI() {
        // Fill the form with existing data
        favouriteSwitch.setOn(contact.favourite, animated: false)
        firstnameTextField.text = contact.firstname
        lastnameTextField.text = contact.lastname
        phoneTextField.text = contact.phone
        emailTextField.text = contact.email
        notesTextField.text = contact.note
        
        // Handle the photo with a fallback
        if !contact.photo.isEmpty, let image = UIImage(named: contact.photo) {
            photoImageView.image = image
        } else {
            photoImageView.image = UIImage(systemName: "person.circle.fill")
        }
        
        // Styling: Round the image
        photoImageView.layer.cornerRadius = photoImageView.frame.size.width / 2
        photoImageView.clipsToBounds = true
    }
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        // 1. Validate the form
        guard isFormValid(mandatoryFieldsArray: textFieldsToValidate) else {
            showInvalidTextFields(mandatoryFieldsArray: textFieldsToValidate)
            return
        }
        
        // 2. Update the existing contact object with new values from UI
        updateContactObject()
        
        // 3. Save to Firebase
        performUpdate()
    }
    
    // MARK: - Logic
    
    private func updateContactObject() {
        contact.firstname = firstnameTextField.text ?? ""
        contact.lastname = lastnameTextField.text ?? ""
        contact.email = emailTextField.text ?? ""
        contact.phone = phoneTextField.text ?? ""
        contact.note = notesTextField.text ?? ""
        contact.favourite = favouriteSwitch.isOn
    }
    
    private func performUpdate() {
        
        guard let userId = Auth.auth().currentUser?.email else { return }
        let service = Repository.sharedRepository
        
        Task {
            do {
                try await service.updateContact(for: userId, withData: contact)
                print("✅ Contact updated successfully")
                
                // 4. Trigger the unwind segue
                self.performSegue(withIdentifier: "unwindAfterEditSave", sender: self)

            } catch {
                print("❌ Update failed: \(error.localizedDescription)")
                // Teaching tip: This is where you would show an error alert to the student
            }
        }
    }
    
}


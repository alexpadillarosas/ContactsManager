//
//  EditContactTVC.swift
//  ContactsManager
//
//  Created by alex on 20/7/2024.
//

import UIKit
import FirebaseAuth

class EditContactTVC: UITableViewController {
    
    var contact : Contact!
    
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var favouriteSwitch: UISwitch!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        favouriteSwitch.setOn(contact.favourite, animated: true)
        firstnameTextField.text = contact.firstname
        lastnameTextField.text = contact.lastname
        phoneTextField.text = contact.phone
        emailTextField.text = contact.email
        notesTextField.text = contact.note
        
        //For the image
        if !contact.photo.isEmpty && UIImage(named: contact.photo) != nil {
            photoImageView.image = UIImage(named: contact.photo)
            
        }else{//This else is needed to reset the default image, else gets cached it and display the wrong one whenever the image cannot be found in the project
            photoImageView.image = UIImage(systemName: "person.circle.fill")
        }
        //Round the Image View
        photoImageView.layer.cornerRadius = photoImageView.frame.size.width / 2
        photoImageView.clipsToBounds = true
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if firstnameTextField.text.isBlank {
            showAlertMessage(title: "Validation", message: "Firstname is mandatory")
            return false
        }

        if lastnameTextField.text.isBlank {
            showAlertMessage(title: "Validation", message: "Lastname is mandatory")
            return false
        }

        if emailTextField.text.isBlank {
            showAlertMessage(title: "Validation", message: "Email is mandatory")
            return false
        }
        
        if phoneTextField.text.isBlank {
            showAlertMessage(title: "Validation", message: "Phone is mandatory")
            return false
        }
        
        return true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        // placed this if conditional as a safeguard, so whenever we create a segue to go to another view controller,
        // this code won't break, it will only work when going back to ShowContactsTableVC
        if segue.destination is ShowContactsTVC {
            
            //Get all possible changes done in the UI
            contact.firstname = firstnameTextField.text!
            contact.lastname = lastnameTextField.text!
            contact.email = emailTextField.text!
            contact.favourite = favouriteSwitch.isOn
            contact.phone = phoneTextField.text!
            contact.note = notesTextField.text!
            
            let service = Repository()
            //Get the logged user Id
            let userAuthId = Auth.auth().currentUser?.uid
            //Update the contact
            if service.updateContact(for: userAuthId!, withData: contact){
                 print("contact updated")
            }
        }
        
    }
    

}

//
//  AddContactTVC.swift
//  ContactsManager
//
//  Created by alex on 23/7/2024.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class AddContactTVC: UITableViewController {

    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextFIeld: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var favouriteSwitch: UISwitch!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var photoTextField: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.destination is ShowContactsTVC {
            
            //create an contact object
            let contact = Contact(firstname: firstnameTextField.text!,
                                  lastname: lastnameTextField.text!,
                                  email: emailTextFIeld.text!,
                                  phone: phoneTextField.text!,
                                  photo: photoTextField.text!,
                                  note: notesTextField.text!,
                                  favourite: favouriteSwitch.isOn,
                                  registered: Timestamp(date: Date()),
                                  tags: [String]())
            
            //Get the user id from the current logged in user.
            let userAuthId = Auth.auth().currentUser?.uid
            //Create a instance of the repository class
            let service = Repository()
            //Add a contact to the logged in user
            if service.addContact(for: userAuthId!, withData: contact){
                print("contact saved")
            }
            
            
        }
        
    }


}

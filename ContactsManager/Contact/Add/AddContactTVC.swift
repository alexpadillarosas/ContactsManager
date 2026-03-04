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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var favouriteSwitch: UISwitch!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var photoTextField: UITextField!
    
    /* example for validation using different components: https://www.google.com/search?q=ios+uikit+form+validation&rlz=1C5CHFA_enAU916AU916&oq=ios+uikit+form+validation+&gs_lcrp=EgZjaHJvbWUyBggAEEUYOTIKCAEQABiABBiiBDIKCAIQABiABBiiBDIKCAMQABiABBiiBDIKCAQQABiABBiiBNIBCTExNzQ4ajBqN6gCALACAA&sourceid=chrome&ie=UTF-8#fpstate=ive&vld=cid:f54a8c92,vid:5Rn6JJAuyK0,st:0
    */
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }


    private func showInvalidTextFilds(){
//        var totalInvalidComponents : Int = 0
        if firstnameTextField.text.isBlank {
//            Move these 2 to the extension class
//            firstnameTextField.layer.borderColor = UIColor.red.cgColor
//            firstnameTextField.layer.borderWidth = 0.5
            firstnameTextField.showInvalidBorder()
//            totalInvalidComponents  = totalInvalidComponents + 1

        }else{
//            Move these 2 to the extension class
//            firstnameTextField.layer.borderColor = UIColor.lightGray.cgColor
//            firstnameTextField.layer.borderWidth = 0.0
            firstnameTextField.removeInvalidBorder()

        }
        /**
         using ternary operators to shorten the code:
         (condition ? valueIfTrue : valueIfFalse)
         */
        lastnameTextField.text.isBlank ? lastnameTextField.showInvalidBorder() : lastnameTextField.removeInvalidBorder()
        
        emailTextField.text.isBlank ? emailTextField.showInvalidBorder() : emailTextField.removeInvalidBorder()

        phoneTextField.text.isBlank ? phoneTextField.showInvalidBorder() : phoneTextField.removeInvalidBorder()
            
    }
    /**
     Returns true if the form is valid ( the user has input all mandatory fields )
     else return false
     */
    private func isFormValid() -> Bool {
        //include all your validations here
        if firstnameTextField.text.isBlank ||
            lastnameTextField.text.isBlank ||
            emailTextField.text.isBlank ||
            phoneTextField.text.isBlank {
            return false
        }else{
            return true
        }
    
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if !isFormValid() {
            showInvalidTextFilds()
            return false
        }
        return true
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
                                  email: emailTextField.text!,
                                  phone: phoneTextField.text!,
                                  photo: photoTextField.text!,
                                  note: notesTextField.text!,
                                  favourite: favouriteSwitch.isOn,
                                  registered: Timestamp(date: Date()),
                                  tags: [String]())
            
            //Get the user id from the current logged in user.
            let userId = Auth.auth().currentUser?.email
            //Create a instance of the repository class
            let service = Repository.sharedRepository
            
            Task{
                do{
                    try await service.addContact(for: userId!, withData: contact)
                    // Success: Navigate back or show success message
                    // self.navigationController?.popViewController(animated: true)
                    print("contact saved")
                } catch{
                    print("Contact NOT saved, Error: \(error.localizedDescription)")
                }
            }
            
            
        }
        
    }


}


//
//  ProfileTCV.swift
//  ContactsManager
//
//  Created by alex on 27/7/2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import UniformTypeIdentifiers
class ProfileTVC: UITableViewController {

    @IBOutlet weak var registerAtDatePicker: UIDatePicker!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var dobDatePicker: UIDatePicker!
    
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
    let service = Repository()
    var user : User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        //Get the user id from the current logged in user.
        let userId = Auth.auth().currentUser?.email
        self.saveBarButtonItem.isEnabled = false
        
        service.findUserInfo(for: userId!) { returnedUser in
            //we assign the returned user from the datase into a class property, so we can reuse it everywhere in this class.
            self.user = returnedUser
            
            self.firstnameTextField.text = self.user.firstname
            self.lastnameTextField.text = self.user.lastname
            self.phoneTextField.text = self.user.phone
            self.emailLabel.text = self.user.email
            
            let dobValue = self.user.dob.dateValue()
            self.dobDatePicker.setDate(dobValue, animated: true)
            
            
            let dateValue = self.user.registered.dateValue()
            self.registerAtDatePicker.setDate(dateValue, animated: true)
            self.saveBarButtonItem.isEnabled = true
        }
        
    }
    
    func isDataValid() -> Bool {
        var totalInvalidComponents : Int = 0
        if firstnameTextField.text.isBlank {
            firstnameTextField.showInvalidBorder()
            totalInvalidComponents = totalInvalidComponents + 1
        }else{
            firstnameTextField.removeInvalidBorder()
        }
        
        if lastnameTextField.text.isBlank {
            lastnameTextField.showInvalidBorder()
            totalInvalidComponents = totalInvalidComponents + 1
        }else{
            lastnameTextField.removeInvalidBorder()
        }
        
        if totalInvalidComponents > 0 {
            showAlertMessage(title: "Validation", message: "Please input the required information")
            return false
        }else{
            return true
        }
    }

    /**
     Method used to save user's information
     */
    @IBAction func saveButtonDidPress(_ sender: Any) {
        
        if isDataValid() {
            
            let user = User(id: user.id,
                            firstname: firstnameTextField.text!,
                            lastname: lastnameTextField.text!,
                            email: emailLabel.text!,
                            phone: phoneTextField.text!,
                            photo: "",
                            dob: Timestamp(date: dobDatePicker.date)
            )
            
            _ = service.updateUser(withData: user)
        }
        
    }
    

    /**
     Method used to logout the user and force a new login
     */
    @IBAction func logoutButtonDidPress(_ sender: Any) {
        //Logout the user from firebase authentication
        do {
            try Auth.auth().signOut()
        }catch {
            print("already logged out")
        }
        //redirect the app to the login scene
        let loginViewController = self.storyboard?.instantiateViewController(identifier: "LoginVC") as? UINavigationController
        
        self.view.window?.rootViewController = loginViewController
        self.view.window?.makeKeyAndVisible()
         
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

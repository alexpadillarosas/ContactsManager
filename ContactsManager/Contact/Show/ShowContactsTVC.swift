//
//  ShowContactsTableVC.swift
//  ContactsManager
//
//  Created by alex on 11/5/2024.
//

import UIKit
import FirebaseAuth
class ShowContactsTVC: UITableViewController {

    var selectedContact : Contact!
    var userAuthId : String!
    
    //This is a reference to the UITableViewController in the storyboard, so we can programmatically manipulate it
    @IBOutlet var showContactsTVC: UITableView!
    
    let service = Repository() //An instance of our Service (class that works with firebase/firestore)
    var contacts = [Contact]() //An array holding all contacts from our database
       
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        /*
        var users = [User]()
        _ = service.db.collection("users")
            .addSnapshotListener { querySnapshot, error in
                if let documents = querySnapshot?.documents {
                    users = documents.compactMap({ queryDocumentSnapshot -> User? in
                        let data = queryDocumentSnapshot.data()
                        
                        return User(id: queryDocumentSnapshot.documentID, dictionary: data)
                    })
                    
                    for user in users {
                        print(user.firstname)
                    }
                   // self.contactsTableView.reloadData()
                }else{
                    print("Error fetching documents \(error!)")
                    returnqu
                }
            }
        */
        
        userAuthId = Auth.auth().currentUser?.uid
        print("User id in Show Contacts: \(userAuthId ?? "NIL")")
        //to access a subcollections we can also create references by specifying the path to a document or collection as a string, with path components separated by a forward slash (/)
        
        //We call the trailing closure
        
        service.findUserContacts(fromCollection: "users/" + userAuthId! + "/contacts"){  (returnedCollection) in
            self.contacts = returnedCollection
            self.showContactsTVC.reloadData()
        }

        print("total \(contacts.count)")
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return contacts.count
    }

    
    /**
     iOS will call this method whenever the row appears on the scene
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ContactTVCell
        
        /**Get the data (Contact) we will display on this cell, since iOS give as the row the for which this method is being executed in the parameter indexPath, we can use the index to get that specific contact in the array
         */
        let contact = contacts[indexPath.row]

        // Configure the cell...
        cell.fullNameLabel.text = contact.firstname + " " + contact.lastname
        cell.phoneLabel.text = contact.phone
        
        if contact.favourite {
            //Since we have set the property Symbol Scale to Medium, whenever we set it programmatically, we have to specify it as well
            let smallStarImage = UIImage(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(scale: UIImage.SymbolScale.small))
            cell.favouriteButton.setImage(smallStarImage, for: UIControl.State.normal)
        }else {
            //we remove the image from the button
            cell.favouriteButton.setImage(UIImage(), for: UIControl.State.normal)
        }
        
        //For the picture
        if !contact.photo.isEmpty && UIImage(named: contact.photo) != nil {
            cell.photoImageView.image = UIImage(named: contact.photo)
            
        }else{//This else is needed to reset the default image, else gets cached it and display the wrong one whenever the image cannot be found in the project
            cell.photoImageView.image = UIImage(systemName: "person.circle.fill")
        }
        //Round the Image View
        cell.photoImageView.layer.cornerRadius = cell.photoImageView.frame.size.width / 2
        cell.photoImageView.clipsToBounds = true
        
        
        return cell
    }
    
    /**
        This method will set selectedContact with the contact's data selected by the user in the UI ( when the user tap on the table view controller)
     */
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedContact = contacts[indexPath.row]
        return indexPath
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    /**
     This method enables delete and edit on the TableViewController
     We will only use delete
     */
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let contact = contacts[indexPath.row]
            deleteConfirmationMessage(title: "Delete", 
                                      message: "Are you sure you want to permanently delete \(contact.firstname) \(contact.lastname) ?",
                delete: {
                    if self.service.deleteContact(withContactId: contact.id, for: self.userAuthId) {
                        print("Contact Deleted")
                    }
                }, cancel: {
                    print("Cancelled")
                })
            
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let viewContactsTVC = segue.destination as? ViewContactTVC{
            viewContactsTVC.contact = selectedContact
        }
    }
    
    /**
     We need this method since we use unwind segue from 2 places to this TableViewController:
     EditContactTVC and AddContactTVC
     */
    @IBAction func unwindToShowTableVC(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        
        if sourceViewController is EditContactTVC {
            
        }
        
        if sourceViewController is AddContactTVC {
            
        }
    }
    
}

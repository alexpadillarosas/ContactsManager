//
//  ShowContactsTableVC.swift
//  ContactsManager
//
//  Created by alex on 11/5/2024.
//

import UIKit
import FirebaseAuth
class ShowContactsTableVC: UITableViewController {

    @IBOutlet var showContactsTV: UITableView!
    let service = ContactRespository() //An instance of our Service (class that works with firebase/firestore)
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
        
        let userAuthId = Auth.auth().currentUser?.uid
        print("User id in Show Contacts: \(userAuthId ?? "NIL")")
        //to access a subcollections we can also create references by specifying the path to a document or collection as a string, with path components separated by a forward slash (/)
        
        //We call the trailing closure
        
        service.findUserContacts(fromCollection: "users/" + userAuthId! + "/contacts"){  (returnedCollection) in
            self.contacts = returnedCollection
            self.showContactsTV.reloadData()
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
        
        //Get the data (Contact) we will display on this cell
        
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
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ShowContactsTableVC.swift
//  ContactsManager
//
//  Created by alex on 11/5/2024.
//

import UIKit
import FirebaseAuth
/**

 */
class ShowContactsTVC: UITableViewController , UISearchBarDelegate {

    @IBOutlet weak var MyNav: UINavigationItem!
    
    
    /**
     Search Block
     For the searchBar to work we need to make ShowContactsTVC implement UISearchBarDelegete protocol and then implement the function that will perform the search,
     in this case we call it:    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
     */
    @IBOutlet weak var searchUiSearchBar: UISearchBar!
    //This variable tracks whether the user is performing a search or not.
    var searching = false
    //This array will keep only the row number of the contacts that satisfies the search
    var matches = [Int]()

    
    
    var selectedContact : Contact!
//    var userAuthId : String!
    var userId: String!
    
    //This is a reference to the UITableViewController in the storyboard, so we can programmatically manipulate it
    @IBOutlet var showContactsTVC: UITableView!
    
    let service = Repository.sharedRepository //A singleton instance of our Service (class that works with firebase/firestore)
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
        
        //here we want to have a reference to the tab bar item icon, so we can add a badge with the number of contacts
        let contactsNC = self.parent as! ContactsNC
        contactsNC.contactsTabBarItem.badgeColor = .systemBlue

        
        userId = Auth.auth().currentUser?.email
        print("User id in Show Contacts: \(userId ?? "NIL")")
        //to access a subcollections we can also create references by specifying the path to a document or collection as a string, with path components separated by a forward slash (/)
        
        //We call the trailing closure
        
        service.findUserContacts(fromCollection: "users/" + userId! + "/contacts"){  (returnedCollection) in
            self.contacts = returnedCollection
            self.showContactsTVC.reloadData()
            //We update the badge on the contacts item to inform the user the number of contacts registered in the app
            contactsNC.contactsTabBarItem.badgeValue = "\(self.contacts.count)"
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
        // If a search is being perfomed, the number of rows to display in the TVC will be comming from the filtered array: matches.
        // else we will get all contacts from the contacts array
        return searching ? matches.count : contacts.count
    }

    /**
     iOS will call this method whenever the row appears on the scene
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ContactTVCell
        
        /**Get the data (Contact) we will display on this cell, since iOS give as the row the for which this method is being executed in the parameter indexPath, we can use the index to get that specific contact in the array
         */

        //Now that we have implemented the search functionality, we will get data depending on searching.
        //When true, we get the only the contacts whose indexes have been stored in the matches array.
        //else we will get all contacts.
        let contact = searching ? contacts[matches[indexPath.row]] : contacts[indexPath.row]

        // Configure the cell...
        cell.fullNameLabel.text = contact.firstname + " " + contact.lastname
        cell.phoneLabel.text = contact.phone
        
        if contact.favourite {
            //Since we have set the property Symbol Scale to Medium, whenever we set it programmatically, we have to specify it as well
            let largeStarImage = UIImage(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(scale: UIImage.SymbolScale.large))
            cell.favouriteButton.setImage(largeStarImage, for: UIControl.State.normal)
        }else {
            //we remove the image from the button
            let largeStarImage = UIImage(systemName: "star", withConfiguration: UIImage.SymbolConfiguration(scale: UIImage.SymbolScale.large))
            cell.favouriteButton.setImage(largeStarImage, for: UIControl.State.normal)
        }
        
        //For the picture
        if !contact.photo.isEmpty && UIImage(named: contact.photo) != nil {
            cell.photoImageView .image = UIImage(named: contact.photo)
            
        }else{//This else is needed to reset the default image, else gets cached it and display the wrong one whenever the image cannot be found in the project
            cell.photoImageView.image = UIImage(systemName: "person.circle.fill")
        }
        //Round the Image View
        cell.photoImageView.layer.cornerRadius = cell.photoImageView.frame.size.width / 2
        cell.photoImageView.clipsToBounds = true
        
        /**
         This code is only to store the row number in the buttons tag
         */
        cell.callButton.tag = indexPath.row
        // Add a target to your button making sure that you return the sender like so: ( before doing this, create the method callButtonDidPress
        cell.callButton.addTarget(self, action: #selector(callButtonDidPress(sender:)), for: UIControl.Event.touchUpInside)
        
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
            
            //Get the contact depending if we are performing a search or not
            let contact = searching ? contacts[matches[indexPath.row]] : contacts[indexPath.row]
            deleteConfirmationMessage(title: "Delete",
                                      message: "Are you sure you want to permanently delete \(contact.firstname) \(contact.lastname) ?",
                delete: {
                    if self.service.deleteContact(withContactId: contact.id, for: self.userId) {
                        print("Contact Deleted")
                        //If we perform the delete action while searching, then we also need to delete index from that array
                        if self.searching {
                            self.matches.remove(at: indexPath.row)
                        }
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
    
    /**
     Function that performs the search using the UISearchBar we dropped in the Storyboard, for this to work you must make this class ShowContactsTVC to conform 
     UISearchBarDelegate protocol
     */
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("\(searchText)")
        if !searchText.isBlank {
            searching = true
            matches.removeAll()
            
            var fullname : String
            for index in 0..<contacts.count {
                fullname = contacts[index].firstname + " " + contacts[index].lastname
                if fullname.lowercased().contains(searchText.lowercased()) {
                    matches.append(index)
                }
            }
            print("found \(matches.count) matches")
        }else{
            searching = false
        }
        print("searching: \(searching)")
        self.showContactsTVC.reloadData()
    }
    
    /**
     Function that handles touches for the phone icon
     */
    @objc func callButtonDidPress(sender: UIButton) {
        // Now you can easily access the sender's tag, (which is equal to the indexPath.row of the tapped button)
        // Access the selected cell's index path using the sender's tag like so :
        let selectedIndex = IndexPath(row: sender.tag, section: 0)
        // And finally do whatever you need using this index :
        tableView.selectRow(at: selectedIndex, animated: true, scrollPosition: .none)
        // Now if you need to access the selected cell instead of just the index path, you could easily do so by using the table view's cellForRow method
        let selectedCell = tableView.cellForRow(at: selectedIndex) as! ContactTVCell
        
        selectedCell.backgroundColor = .green
    }
    
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

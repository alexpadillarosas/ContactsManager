//
//  ContactsCollectionViewController.swift
//  ContactsManager
//
//  Created by alex on 12/11/2024.
//

import UIKit
import FirebaseAuth


//For the UI please watch this video: https://www.youtube.com/watch?v=TQOhsyWUhwg

class ShowContactsCVC: UICollectionViewController {

    var selectedContact : Contact!
    @IBOutlet var showContactsCollectionView: UICollectionView!
    let service = Repository.sharedRepository //A singleton instance of our Service (class that works with firebase/firestore)
    var contacts = [Contact]() //An array holding all contacts from our database
    var userLoggedInEmail : String!
    
    let itemsPerRow : CGFloat = 2 // the number of items to display per row
    
    let minCellWidth: CGFloat = 150 // minimum width for a cell
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        
        //Set the borders and insets for the collection view, we will set up the dimensions of the table view cell programmatically, any changes done in storyboard will be omitted.
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        super.collectionView.collectionViewLayout = layout
        
        userLoggedInEmail = Auth.auth().currentUser?.email
        print("User id in Show Contacts: \(userLoggedInEmail ?? "NIL")")
        //to access a subcollections we can also create references by specifying the path to a document or collection as a string, with path components separated by a forward slash (/)
        
        //We call the trailing closure
        
        service.findUserContacts(fromCollection: "users/" + userLoggedInEmail! + "/contacts"){  (returnedCollection) in
            self.contacts = returnedCollection
            self.showContactsCollectionView.reloadData()
            //We update the badge on the contacts item to inform the user the number of contacts registered in the app

        }

        print("total \(contacts.count)")
        
    }



    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contacts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCVCell.identifier, for: indexPath) as! ContactCVCell
    
        let contact = contacts[indexPath.row]
        // Configure the cell
        cell.setup(fullname: "\(contact.firstname) \(contact.lastname)",
                   phone: contact.phone,
                   favourite: contact.favourite,
                   photo: contact.photo)
    
        return cell
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        

        let sectionInsets = layout.sectionInset.left + layout.sectionInset.right
        let spacing = layout.minimumInteritemSpacing

        //if you uncomment the following then comment th next 2 lines after this commented out block
        /*
        let isPortrait = view.bounds.height > view.bounds.width
        let columns: CGFloat
        When we are in portrait mode I will always want 2 columns
        if isPortrait {
            columns = 2
        } else {
            let availableWidth = collectionView.bounds.width - sectionInsets
            columns = floor((availableWidth + spacing) / (minCellWidth + spacing))
        }
         */
        
        let availableWidth = collectionView.bounds.width - sectionInsets
        let columns = max(1, floor((availableWidth + spacing) / (minCellWidth + spacing)))
        
        
        let totalSpacing = sectionInsets + spacing * (columns - 1)
        let width = (collectionView.bounds.width - totalSpacing) / columns
        /**
         Here configure height depending on the hight you want to have for your cards (UICollectionViewCells)
            Height 30% bigger than Width suits this design
         */
        layout.itemSize = CGSize(width: floor(width), height: width * 1.3)
        
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        selectedContact = contacts[indexPath.row]
        return true
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if let viewContactsTVC = segue.destination as? ViewContactTVC{
            viewContactsTVC.contact = selectedContact
        }
        
    }
    
    
}

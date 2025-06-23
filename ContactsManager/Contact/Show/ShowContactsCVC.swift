//
//  ContactsCollectionViewController.swift
//  ContactsManager
//
//  Created by alex on 12/11/2024.
//

import UIKit
import FirebaseAuth

private let reuseIdentifier = "reuseIdentifier2"

class ShowContactsCVC: UICollectionViewController {

    @IBOutlet var showContactsCollectionView: UICollectionView!
    let service = Repository() //An instance of our Service (class that works with firebase/firestore)
    var contacts = [Contact]() //An array holding all contacts from our database
    var userAuthId : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnVieminamiwWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        userAuthId = Auth.auth().currentUser?.uid
        print("User id in Show Contacts: \(userAuthId ?? "NIL")")
        //to access a subcollections we can also create references by specifying the path to a document or collection as a string, with path components separated by a forward slash (/)
        
        //We call the trailing closure
        
        service.findUserContacts(fromCollection: "users/" + userAuthId! + "/contacts"){  (returnedCollection) in
            self.contacts = returnedCollection
            self.showContactsCollectionView.reloadData()
            //We update the badge on the contacts item to inform the user the number of contacts registered in the app

        }

        print("total \(contacts.count)")
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return contacts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ContactCVCell
    
        let contact = contacts[indexPath.row]
        // Configure the cell
        if !contact.photo.isEmpty && UIImage(named: contact.photo) != nil {
            cell.contactImageView.image = UIImage(named: contact.photo)
            
        }else{//This else is needed to reset the default image, else gets cached it and display the wrong one whenever the image cannot be found in the project
            cell.contactImageView.image = UIImage(systemName: "person.circle.fill")
        }
    
        return cell
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

}

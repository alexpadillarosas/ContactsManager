//
//  ContactRespository.swift
//  ContactsManager
//
//  Created by alex on 11/5/2024.
//

import Foundation
import FirebaseFirestore

class Repository {
    static let sharedRepository = Repository()
    let db = Firestore.firestore()

    //        whereField("country", in: ["USA", "Japan"])
    //        _ = db.collection(name).whereField("userId", isEqualTo: userId)

    //This is a trailing closure: A function whose last parameter is a closure
    //the closure receives an contact's array and returns nothing
    func findUserContacts( fromCollection name : String, completion : @escaping ([Contact]) -> ()){

        //here when ordering by 2 different fields, firestore will force you to create an index ( which it does makes sense )
        //check the log and there will be a url you can click, firestore will suggest you which type of index to create, after it
        //you will be able to run the app again. Check the index status is enabled, else you will have to wait.
        var contacts = [Contact]()
        _ = db.collection(name)
            .order(by: "firstname")
            .order(by: "lastname", descending: false)
            .addSnapshotListener { snapshot, error in  //we add a listener, so we can listen for updates made to our db, it returns a current snapshot with the found data, and an error if there is any
                if let documents = snapshot?.documents { //we unwrap the documents inside of the snapshot
                    
                    contacts = documents.compactMap({ doc -> Contact? in    //we transform (by using compactMap) where we receive a document represented by the variable called doc and return a Contact
                        let data = doc.data()
                        return Contact(id: doc.documentID, dictionary: data) // using the initializer that receives the docId and the data in a dictionary
                    })
                    
                    for contact in contacts {
                        print(contact.toString())
                    }
                    completion(contacts) //we execute the completion which is a block of code received as parameter
                   // self.contactsTableView.reloadData()
                     
                }else{
                    print("Error fetching documents \(error!)")
                    return
                }
            }
    }
    
    func addUser(withData user: User) -> Bool {
        var result = true
        let dictionary : [String: Any] = [
            "firstname": user.firstname as String,
            "lastname": user.lastname as String,
            "email": user.email as String,
            "phone": user.phone as String,
            "photo": user.photo as String,
            "dob": user.registered ?? FieldValue.serverTimestamp(),
            "registered": user.registered ?? FieldValue.serverTimestamp() //if user.registered is nil then assignt the server timestamp
//            "contacts": user.contacts
        ]
        //we set a particular Id so we use it
        db.collection("users").document(user.id).setData(dictionary){ error in
            if let error = error {
                print("user could not be added \(user.email), error: \(error)")
                result = false
            }
        }
        return result
    }
    
    func findUserInfo(for userId : String, completion : @escaping (User) -> ()) {
        var user : User!
        //Get a reference to the document by providing the userId
        let userRef = db.collection("users").document(userId)
        //get the document, notice that this as other methods are asynchronous, therefore it won't work while debugging, it will not execute the method.
        //The guard and the rest of the code inside getDocument will be executed once the response from the db comes back
        userRef.getDocument { (document, error) in
            guard error == nil else {
                print("Error getting the user information \(error!.localizedDescription)")
                return
            }
            //unwrap the document, and also check that exists
            if let document = document, document.exists {
                //get the data in a dictionary
                let data = document.data()
                //unwrap the dictionary
                if let data = data {
//                    print(data)
                    user = User(id: userId, dictionary: data)
                    //call the closure passing a the user object
                    completion(user)
                }
            }else{
                print("User infor Document does not exist")
                return
            }
        }
    }
        
    func updateUser(withData user : User) -> Bool {
        var result = true

        let dictionary : [String : Any] = [
            "firstname": user.firstname as String,
            "lastname": user.lastname as String,
            "phone": user.phone as String,
            "photo": user.photo as String,
            "dob": user.dob as Timestamp
        ]
        
        db.collection("users").document(user.email).updateData(dictionary){ error in
            if let error = error {
                print("Error updating user information: \(error)")
                result = false
            }else{
                print("User information updated")
            }
        }
        return result
    }
    
    
    
    
    func updateContact(for userId: String, withData contact: Contact) -> Bool {
        var result = true

        let dictionary : [String : Any] = [
            "firstname": contact.firstname as String,
            "lastname": contact.lastname as String,
            "email": contact.email as String,
            "phone": contact.phone as String,
            "photo": contact.photo as String,
            "favourite": contact.favourite as Bool,
            "note": contact.note as String
        ]
        
        db.collection("users/" + userId + "/contacts").document(contact.id!).updateData(dictionary){ error in
            if let error = error {
                print("Error updating document: \(error)")
                result = false
            }else{
                print("Document updated")
            }
        }

        return result
    }
    
    func addContact(for userId: String, withData contact: Contact) -> Bool {
        var result = true
        //let userAuthId = Auth.auth().currentUser?.uid
        print("User id in Show Contacts: \(userId)")
        
        let dictionary : [String: Any] = [
            "firstname": contact.firstname as String,
            "lastname": contact.lastname as String,
            "email": contact.email as String,
            "favourite": contact.favourite as Bool,
            "note": contact.note as String,
            "phone": contact.phone as String,
            "photo": contact.photo as String,
            "registered": FieldValue.serverTimestamp(),
            "tags": [String]()
        ]
        
        /*
        db.collection("users/" + userId + "/contacts").addDocument(data: dictionary){ error in
            if let error = error {
                print("Contact has not been added: \(contact.email) \(error)")
                result = false
            }else{
                print("Contact Added: \(contact.email)")
            }
            
        }
         */
        let newContactRef = db.collection("users").document(userId).collection("contacts").document()
        
        newContactRef.setData(dictionary) { error in
            if let error = error {
                print("Error adding the document \(error.localizedDescription)")
                result = false
            }else{
                print("Contact was added")
            }
        }
        
        return result
    }
    
    func deleteContact(withContactId contactId: String, for userId: String) -> Bool {
        var result = true
        
        db.collection("users/" + userId + "/contacts").document(contactId).delete(){ error in
            if let error = error {
                print("Error removing document: \(error.localizedDescription)")
                result = false
            }else{
                print("Document successfully deleted")
            }
        }
        return result
    }
    
}

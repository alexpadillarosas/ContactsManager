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
                
                //guard we bring data from the database
                guard let documents = snapshot?.documents else{
                    print("No documents retrieved ")
                    completion(contacts) //set the empty array
                    return
                }
                //Transform all documents into Contact objects 1 by 1, using the documents constant, as we have passed the guard.
                contacts = documents
                .compactMap { doc -> Contact in
                    //doc.data() returns a dictionary
                    //doc.documentID is the Document Id brought from the database
                    //We create an instance of contact mapping all data from the dictionary into it, using the initializer
                    return Contact(id: doc.documentID, dictionary: doc.data())
                }
                //Print it to double check we get the data
                for contact in contacts {
                    print(contact.toString())
                }
                //We've got all contacts from the db in the variable contacts.
                //Set the contacts we've got from the db to the closure (receives an array of contacts, returns nothing)
                //So after calling the function the param passed as array of contacts when calling findUserContacts will be set with the database data(contacts)
                completion(contacts) //we execute the completion which is a block of code received as parameter
                    
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
            
            //Guard the error is nil (no error) else return
            guard error == nil else {
                print("User could not be added: \(error!.localizedDescription)") //using ! to force unwrapp error, it is fine as at this point we know error is not nil
                result = false
                return
            }
            print("User added: \(user.email)")
            
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
            
            //Guard the error is nil (no error) else return
            guard error == nil else {
                print("Error updating user information: \(error!.localizedDescription)") //using ! to force unwrapp error, it is fine as at this point we know error is not nil
                result = false
                return
            }
            print("User information updated")
            
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
            //Guard the error is nil (no error) else return
            guard error == nil else {
                print("Error updating document: \(error!.localizedDescription)") //using ! to force unwrapp error, it is fine as at this point we know error is not nil
                result = false
                return
            }
            print("Document updated")

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
        
        let newContactRef = db.collection("users").document(userId).collection("contacts").document()
        
        newContactRef.setData(dictionary) { error in
            //Guard the error is nil (no error) else return
            guard error == nil else {
                print("Error adding the document: \(error!.localizedDescription)") //using ! to force unwrapp error, it is fine as at this point we know error is not nil
                result = false
                return
            }
            print("Contact was added")
            
        }
        
        return result
    }
    
    func deleteContact(withContactId contactId: String, for userId: String) -> Bool {
        var result = true
        
        db.collection("users/" + userId + "/contacts").document(contactId).delete(){ error in
            
            //Guard the error is nil (no error) else return
            guard error == nil else {
                print("Error deleting document: \(error!.localizedDescription)") //using ! to force unwrapp error, it is fine as at this point we know error is not nil
                result = false
                return
            }
            print("Document successfully deleted")
                
        }
        return result
    }
    
}

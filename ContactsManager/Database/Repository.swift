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
    //the closure receives an contact's array and returns a listener
    func findUserContacts( fromCollection name : String, completion : @escaping ([Contact]) -> ()) -> ListenerRegistration {

        //here when ordering by 2 different fields, firestore will force you to create an index ( which it does makes sense )
        //check the log and there will be a url you can click, firestore will suggest you which type of index to create, after it
        //you will be able to run the app again. Check the index status is enabled, else you will have to wait.
        var contacts = [Contact]()
        let listener = db.collection(name)
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
        //Clean up: return the listener so the caller can stop it later
        return listener
    }
    
    func addUser(withData user: User) async throws {
        // 1. Prepare the data using our model helper
        let data = user.toDictionary()
        
        // 2. Use the provided user.id (from Auth) to set the document
        let userRef = db.collection("users").document(user.email)
        
        // 3. Perform the async write
        // This will 'throw' an error if the network is down or permissions fail
        try await userRef.setData(data)
        
        print("User successfully added: \(user.email)")
    }

    
    func findUserInfo(for userId: String) async throws -> User? {
        // 1. Get the document reference
        let userRef = db.collection("users").document(userId)
        
        // 2. Await the document snapshot
        // This replaces the nested completion handler block
        let document = try await userRef.getDocument()
        
        // 3. Check if the document exists and has data
        guard document.exists, let data = document.data() else {
            print("User document does not exist for ID: \(userId)")
            return nil
        }
        
        // 4. Initialize our User object using the dictionary
        return User(id: userId, dictionary: data)
    }

    
    func updateUser(withData user: User) async throws {
        // 1. Guard against a missing ID 
        guard let uid = user.id, !uid.isEmpty else {
            throw NSError(domain: "AppError", code: 400, userInfo: [NSLocalizedDescriptionKey: "User ID is missing"])
        }

        // 2. Prepare the update dictionary
        // Senior tip: Don't update 'email' or 'registered' here to prevent accidental overwrites
        let dictionary: [String: Any] = [
            "firstname": user.firstname,
            "lastname": user.lastname,
            "phone": user.phone,
            "photo": user.photo,
            "dob": user.dob ?? FieldValue.serverTimestamp() // Safe fallback
        ]
        
        // 3. Reference by user.id (UID)(which is the email in this case)
        let userRef = db.collection("users").document(uid)
        
        // 4. Perform the update and await the server response
        try await userRef.updateData(dictionary)
        
        print("Profile for \(user.email) updated successfully")
    }

    
    func updateContact(for userId: String, withData contact: Contact) async throws {
        // 1. Guard against a missing ID to avoid force-unwrapping crashes
        guard let contactId = contact.id else {
            print("Error: Attempted to update a contact without an ID")
            return
        }
        
        // 2. Use your existing dictionary mapping
        let data = contact.toDictionary()
        
        // 3. Reference the specific document using the cleaner path syntax
        let contactRef = db.collection("users")
                            .document(userId)
                            .collection("contacts")
                            .document(contactId)
        
        // 4. Perform the update and await the result
        try await contactRef.updateData(data)
        
        print("Contact \(contactId) updated successfully")
    }
    
    func addContact(for userId: String, withData contact: Contact) async throws {
        // We use the representation we defined in the model
        let data = contact.toDictionary()
        
        // Create the reference
        let newContactRef = db.collection("users")
                              .document(userId)
                              .collection("contacts")
                              .document()
        
        // Using 'try await' allows the caller to catch any network/permission errors
        try await newContactRef.setData(data)
        
        // Update the local object with the Firestore-generated ID
        contact.id = newContactRef.documentID
        
        print("Contact added successfully with ID: \(contact.id!)")
    }
    
    func deleteContact(withContactId contactId: String, for userId: String) async throws {
        // 1. Reference the document path clearly
        let contactRef = db.collection("users")
                            .document(userId)
                            .collection("contacts")
                            .document(contactId)
        
        // 2. Await the deletion. This ensures the function doesn't 'finish'
        // until the server confirms the record is gone.
        try await contactRef.delete()
        
        print("Document \(contactId) successfully deleted")
    }
    
}

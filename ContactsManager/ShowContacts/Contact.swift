//
//  Contact.swift
//  ContactsManager
//
//  Created by alex on 11/5/2024.
//

import Foundation
import FirebaseFirestore
class Contact {
    var id : String!
    var firstname : String
    var lastname : String
    var email : String
    var phone : String
    var photo : String
    var note : String
    var favourite : Bool
    var registered : Timestamp
    var tags : [String]
    
    //Default initializer, it will be used whenever we want to create a new contact, and therefore we won't know the id as it's autogenerated by firestore
    init(firstname: String, lastname: String, email : String, phone: String, photo: String, note: String, favourite: Bool, registered: Timestamp, tags: [String]) {
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.phone = phone
        self.photo = photo
        self.note = note
        self.favourite = favourite
        self.registered = registered
        self.tags = tags
    }

    //This initializer will be used whenever we fetch a contact from the database (usually via a query so we get a batch of contacts), an existing contact has already a autogenerated id
    convenience init(id: String, firstname: String, lastname: String, email: String, phone: String, photo: String, note: String, favourite: Bool, registered: Timestamp, tags: [String]) {
        self.init(firstname: firstname, lastname: lastname, email: email, phone: phone, photo: photo, note: note, favourite: favourite, registered: registered, tags: tags)
        self.id = id
    }

    //This initializer will be used whenever we want to fetch a contact from the database by id, we know the autogenerated id before hand, but none of the other fields
    convenience init(id : String){
        self.init(firstname: "", lastname: "", email: "", phone: "", photo: "", note: "", favourite: false, registered: Timestamp(date: Date()), tags: [String]())
        self.id = id
    }

    //This initializer is very handy when we work with firestore, as firestore retrieves the data in a dictionary
    convenience init(id: String, dictionary: [String: Any]) {//The dictionary stores String as keys ("firstname", "lastname", etc) and the values datatypes varies depending on the property, that's why we indicate Any
        self.init(id: id,
                  firstname: dictionary["firstname"] as! String,    //cast to get the stored value as String
                  lastname: dictionary["lastname"] as! String,
                  email: dictionary["email"] as! String,
                  phone: dictionary["phone"] as! String,
                  photo: dictionary["photo"] as! String,
                  note: dictionary["note"] as! String,
                  favourite: dictionary["favourite"] as! Bool,
                  registered: dictionary["registered"] as! Timestamp,
                  tags: dictionary["tags"] as! [String]
        )
    }
   
}



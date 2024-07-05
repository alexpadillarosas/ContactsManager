//
//  User.swift
//  ContactsManager
//
//  Created by alex on 18/5/2024.
//

import Foundation
import FirebaseFirestore
class User {
    
    var id: String!
    var firstname: String
    var lastname: String
    var email: String
    var phone: String
    var photo: String
    var registered: Timestamp!
    var contacts: [Contact] = [Contact]() //initialize the contacts collection to not be nil
    
    init(id: String, firstname: String, lastname: String, email: String, phone: String, photo: String, registered: Timestamp? = nil) {
        self.id = id
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.phone = phone
        self.photo = photo
        self.registered = registered
    }
    
    convenience init (id: String , dictionary: [String: Any]){
        self.init(id: id,
                  firstname: dictionary["firstname"] as! String,
                  lastname: dictionary["lastname"] as! String,
                  email: dictionary["email"] as! String,
                  phone: dictionary["phone"] as! String,
                  photo: dictionary["photo"] as! String,
                  registered: dictionary["registered"] as? Timestamp
                
        )
    }
    
}

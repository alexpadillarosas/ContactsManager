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
    var dob: Timestamp!
    var registered: Timestamp!
    
    
    
    
    init(id: String, firstname: String, lastname: String, email: String, phone: String, photo: String) {
        self.id = id
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.phone = phone
        self.photo = photo
        
    }
    
    init(id: String, firstname: String, lastname: String, email: String, phone: String, photo: String, dob: Timestamp ,registered: Timestamp? = nil) {
        self.id = id
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.phone = phone
        self.photo = photo
        self.dob = dob
        self.registered = registered
    }
    

    
    convenience init (id: String , dictionary: [String: Any]){
        self.init(id: id,
                  firstname: dictionary["firstname"] as! String,
                  lastname: dictionary["lastname"] as! String,
                  email: dictionary["email"] as! String,
                  phone: dictionary["phone"] as! String,
                  photo: dictionary["photo"] as! String,
                  dob: dictionary["dob"] as! Timestamp,
                  registered: dictionary["registered"] as? Timestamp
                
        )
    }
    
    func toDictionary() -> [String: Any]{
        
        // Handle the Timestamp vs FieldValue logic safely
        let dobValue: Any = self.dob ?? FieldValue.serverTimestamp()
        let registeredValue: Any = self.registered ?? FieldValue.serverTimestamp()
        
        return [
            "firstname": firstname,
            "lastname": lastname,
            "email": email,
            "phone": phone,
            "photo": photo,
            "dob": dobValue,
            "registered": registeredValue
        ]
    }
    
    func toString() -> String {
        return "id: \(id ?? "NO ID"), firstname: \(firstname), lastname: \(lastname), email: \(email), phone: \(phone), photo: \(photo), registered: \(registered ?? Timestamp(date: Date()))"
    }
    
}

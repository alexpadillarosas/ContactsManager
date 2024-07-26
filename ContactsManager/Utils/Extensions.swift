//
//  StringExtensions.swift
//  ContactsManager
//
//  Created by alex on 3/5/2024.
//

import Foundation
import UIKit

//Here we are not extending a String, we extend an Optional String,
//so we can ask: is the wrapped value Blank?
extension Optional where Wrapped == String {
    //we create a computed property for the class, whose value will be determined by the return statement
    var isBlank: Bool{
        //if we manage to unwrap it then it means is not nil, else is nil
        guard let notNilBool = self else {
            // as it is nil, we consider nil as blank string
            return true
        }
        //at this point notNilBool is not null, so we can trim the spaces and check is it's empty
        return notNilBool.trimmingCharacters(in:.whitespaces).isEmpty
    }
}

extension Optional where Wrapped  == String {
    var isValidEmail: Bool {
        let emailRegEx = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}

//Here we create an extension for UIViewController so we can call showAlert and deleteConfirmation from any viewController
extension UIViewController {
    func showAlertMessage(title : String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true, completion: nil)
    }
    //We create a function with a trailing closure, so we can pass code to be executed whenever the hit the ok button
    func showAlertMessageWithHandler(title : String, message: String, onComplete : (()-> Void)? ){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let oncompleteAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { action in
            onComplete?()
        }
        
        alert.addAction(oncompleteAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    /**
     Using closures:
     If we want to pass code that will get executed inside of a function as a parameter, then create a closure.
     Think of a closure as a function without name.
     The way to declare this parameters is:   parameter name : ( () -> Void )?
     The question mark ? is optional, if we add it, it means the parameter might contain a value or not, wihout ? it could not be nil.
     */
    
    func deleteConfirmationMessage(title : String, message : String, delete : ( () -> Void )?, cancel: ( () -> Void )? ){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet)
        
        
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete", style: .destructive) {
            action -> Void in delete?()
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .default) {
            action -> Void in cancel?()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
    
        present(alert, animated: true, completion: nil)
        
    }
}



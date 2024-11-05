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

extension String {
    var isBlank : Bool {        
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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


extension UITextField {
    func showInvalidBorder() {
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 0.5
    }
    
    func removeInvalidBorder(){
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.0
    }
    
    func setLeftView(image: UIImage) {
        
        let iconView = UIImageView(frame: CGRect(x: 10, y: 13, width: 25, height: 20)) // set your Own size
        iconView.image = image
        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
//        self.tintColor = .lightGray
         
        
        
    }
    
    enum Direction {
        case Left
        case Right
    }

    // add image to textfield
    // Example calling it:
    // emailTextField.withImage(direction: .Left, image: UIImage(systemName: "envelope")!, colorSeparator: UIColor.lightGray , colorBorder: UIColor.black)
    func withImage(direction: Direction, image: UIImage, colorSeparator: UIColor, colorBorder: UIColor){
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 35))
        mainView.layer.cornerRadius = 5

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 35))
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        view.layer.borderWidth = CGFloat(0.5)
        view.layer.borderColor = colorBorder.cgColor
        mainView.addSubview(view)

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 12.0, y: 6.0, width: 24.0, height: 24.0)
        view.addSubview(imageView)

        let seperatorView = UIView()
        seperatorView.backgroundColor = colorSeparator
        mainView.addSubview(seperatorView)

        if(Direction.Left == direction){ // image left
            seperatorView.frame = CGRect(x: 45, y: 0, width: 5, height: 35)
            self.leftViewMode = .always
            self.leftView = mainView
        } else { // image right
            seperatorView.frame = CGRect(x: 0, y: 0, width: 5, height: 35)
            self.rightViewMode = .always
            self.rightView = mainView
        }

        self.layer.borderColor = colorBorder.cgColor
        self.layer.borderWidth = CGFloat(0.5)
        self.layer.cornerRadius = 5
    }
}

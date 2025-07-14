//
//  ContactCVCell.swift
//  ContactsManager
//
//  Created by alex on 13/11/2024.
//

import UIKit

class ContactCVCell: UICollectionViewCell {
    
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    
    static let identifier = "reuseIdentifier2"
    
    func setup(fullname: String, phone : String, favourite : Bool, photo: String){
        
        fullnameLabel.text = fullname
        phoneLabel.text = phone
        
        if favourite {
            //Since we have set the property Symbol Scale to Medium, whenever we set it programmatically, we have to specify it as well
            let largeStarImage = UIImage(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(scale: UIImage.SymbolScale.large))
            favouriteButton.setImage(largeStarImage, for: UIControl.State.normal)
        }else {
            //we remove the image from the button
            let largeStarImage = UIImage(systemName: "star", withConfiguration: UIImage.SymbolConfiguration(scale: UIImage.SymbolScale.large))
            favouriteButton.setImage(largeStarImage, for: UIControl.State.normal)
        }
        
        //For the picture
        if !photo.isEmpty && UIImage(named: photo) != nil {
            contactImageView .image = UIImage(named: photo)
            
        }else{//This else is needed to reset the default image, else gets cached it and display the wrong one whenever the image cannot be found in the project
            contactImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
    
    
}

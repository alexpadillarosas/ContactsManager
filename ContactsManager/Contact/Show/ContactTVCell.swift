//
//  ContactTVCell.swift
//  ContactsManager
//
//  Created by alex on 21/5/2024.
//

import UIKit

class ContactTVCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var callButton: UIButton!

    static let identifier = "reuseIdentifier"
    
    func setup(fullname : String, favourite : Bool, photo : String, phone: String){
        fullNameLabel.text = fullname
        phoneLabel.text = phone
        
        let starIcon = favourite ? "star.fill" : "star"
        let starImage = UIImage(systemName: starIcon, withConfiguration: UIImage.SymbolConfiguration(scale: UIImage.SymbolScale.large))
        favouriteButton.setImage(starImage, for: UIControl.State.normal)
        
        //For the picture
        if !photo.isEmpty && UIImage(named: photo) != nil {
            photoImageView.image = UIImage(named: photo)
            
        }else{//This else is needed to reset the default image, else gets cached it and display the wrong one whenever the image cannot be found in the project
            photoImageView.image = UIImage(systemName: "person.circle.fill")
        }
        //Round the Image View
        photoImageView.layer.cornerRadius = photoImageView.frame.size.width / 2
        photoImageView.clipsToBounds = true
    }
}


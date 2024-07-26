//
//  ViewContactTVC.swift
//  ContactsManager
//
//  Created by alex on 20/7/2024.
//

import UIKit

class ViewContactTVC: UITableViewController {

    var contact: Contact!
    
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!

    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var notesLabel: UILabel!
    
    @IBOutlet weak var registeredAtLabel: UILabel!
    @IBOutlet weak var favouriteSwitch: UISwitch!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        fullnameLabel.text = contact.firstname + " " + contact.lastname
        phoneButton.setTitle(contact.phone, for: UIControl.State.normal)
        notesLabel.text = contact.note
        favouriteSwitch.setOn(contact.favourite, animated: true)
        emailButton.setTitle(contact.email, for: UIControl.State.normal)
        
        let aDate = contact.registered.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedTimeZoneStr = formatter.string(from: aDate)
        print(formattedTimeZoneStr)
        registeredAtLabel.text = formattedTimeZoneStr
        
        //For the image
        if !contact.photo.isEmpty && UIImage(named: contact.photo) != nil {
            photoImageView.image = UIImage(named: contact.photo)
            
        }else{//This else is needed to reset the default image, else gets cached it and display the wrong one whenever the image cannot be found in the project
            photoImageView.image = UIImage(systemName: "person.circle.fill")
        }
        //Round the Image View
        photoImageView.layer.cornerRadius = photoImageView.frame.size.width / 2
        photoImageView.clipsToBounds = true
         
        
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let editContactTVC = segue.destination as? EditContactTVC {
            editContactTVC.contact = self.contact
        }
            
    }
    

}

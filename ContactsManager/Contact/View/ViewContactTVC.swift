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
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var registeredAtLabel: UILabel!
    @IBOutlet weak var favouriteSwitch: UISwitch!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        fullnameLabel.text = contact.firstname + " " + contact.lastname
        phoneButton.setTitle(contact.phone, for: UIControl.State.normal)
        noteTextField.text = contact.note
        favouriteSwitch.setOn(contact.favourite, animated: true)
        emailButton.setTitle(contact.email, for: UIControl.State.normal)
        
        let aDate = contact.registered.dateValue()
        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedTimeZoneStr = formatter.string(from: aDate)
        print(formattedTimeZoneStr)
        registeredAtLabel.text = formattedTimeZoneStr
        
        
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
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

//
//  SplashController.swift
//  ContactsApp
//
//  Created by Sachin Ahuja on 9/7/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import UIKit

class SplashController: UIViewController {

    var username: String?
    @IBOutlet weak var usernameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SplashController")
    }
    
    @IBAction func jumpIn(_ sender: UIButton) {
        print("jump in with", usernameField.text ?? "")
        
        if let checkUsername = usernameField.text {
            username = checkUsername
            view.endEditing(true)
            performSegue(withIdentifier: "goToMap", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMap" {
            let destinationVC = segue.destination as! MapController
            destinationVC.username = username
        }
    }
    

}

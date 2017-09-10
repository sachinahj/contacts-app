//
//  SplashController.swift
//  ContactsApp
//
//  Created by Sachin Ahuja on 9/7/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import UIKit

class SplashController: UIViewController {

    var dbManager: DBManager = DBManager()
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var jumpIn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Enter a Username"
        jumpIn.layer.cornerRadius = 10.0
        jumpIn.clipsToBounds = true
    }
    
    @IBAction func usernameFieldOnChange(_ sender: UITextField) {
        if usernameField.text! != "" {
            self.title = "Hello \(usernameField.text!)!"
        } else {
            self.title = "Enter a Username"
        }
    }
    
    @IBAction func jumpInOnClick(_ sender: UIButton) {
        if usernameField.text! != "" {
            view.endEditing(true)
            let username = usernameField.text?.trimmingCharacters(in: .whitespaces)
            dbManager.createMe(username: username!)
            performSegue(withIdentifier: "goToMap", sender: self)
        } else {
            usernameField.shake()
        }
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "goToMap" {
//            let destinationVC = segue.destination as! MapController
//            destinationVC.username = username
//        }
//    }
}

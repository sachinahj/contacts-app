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
    @IBOutlet weak var jumpIn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SplashController")
        
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
            username = usernameField.text?.trimmingCharacters(in: .whitespaces)
            view.endEditing(true)
            performSegue(withIdentifier: "goToMap", sender: self)
        } else {
            usernameField.shake()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMap" {
            let destinationVC = segue.destination as! MapController
            destinationVC.username = username
        }
    }
    

}

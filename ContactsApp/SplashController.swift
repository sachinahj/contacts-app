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
        if usernameField.text != "" {
            username = usernameField.text?.trimmingCharacters(in: .whitespaces)
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

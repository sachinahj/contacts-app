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
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var jumpInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Enter a Username"
        jumpInButton.layer.cornerRadius = 10.0
        jumpInButton.clipsToBounds = true
    }
    
    @IBAction func usernameTextFieldOnChange(_ sender: UITextField) {
        if usernameTextField.text! != "" {
            self.title = "Hello \(usernameTextField.text!)!"
        } else {
            self.title = "Enter a Username"
        }
    }
    
    @IBAction func onClickJumpInButton(_ sender: UIButton) {
        if usernameTextField.text! != "" {
            view.endEditing(true)
            let username = usernameTextField.text?.trimmingCharacters(in: .whitespaces)
            dbManager.createMe(username: username!)
            performSegue(withIdentifier: "goToMap", sender: self)
        } else {
            usernameTextField.shake()
        }
    }
    
    deinit {
        print("SplashController: deinit")
    }
}

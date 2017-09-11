//
//  ChatController.swift
//  ContactsApp
//
//  Created by Sachin Ahuja on 9/10/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import UIKit

class ChatController: UIViewController, DBManagerDelegate {

    var dbManager: DBManager = DBManager()

    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ChatController")
        
        self.title = "\(DBManager.friends.count) people"
        
        dbManager.delegate = self
    }
    
    func dbManager(friendsUpdated: Int) {
        print(DBManager.friends.count)
    }
    
    @IBAction func chatTextFieldChanged(_ sender: UITextField) {
        print("chatTextFieldChanged")
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        print("sendButtonPressed")
    }
    
}

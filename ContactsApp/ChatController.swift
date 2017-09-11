//
//  ChatController.swift
//  ContactsApp
//
//  Created by Sachin Ahuja on 9/10/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import UIKit

class ChatController: UIViewController, DBManagerDelegate {

    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ChatController")
        
        self.title = "\(DBManager.friends.count) people"
        DBManager.delegates["ChatController"] = self
    }
    
    func dbManager(friendsUpdated count: Int) {
        self.title = "\(count) people"
    }
    
    @IBAction func chatTextFieldChanged(_ sender: UITextField) {
        print("chatTextFieldChanged")
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        print("sendButtonPressed")
    }
    
    deinit {
        print("ChatController: deinit")
    }
    
}

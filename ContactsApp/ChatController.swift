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
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ChatController")
        
        self.title = "\(DBManager.friends.count) people"
        self.messages = DBManager.messages
        
        DBManager.delegateChat = self
    }
    
    func dbManager(friendsUpdated count: Int) {
        self.title = "\(count) people"
    }
    
    func dbManager(messagesUpdated messages: [Message]) {
        print("ChatController: messagesUpdated", messages.count)
        self.messages = messages
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        if let text = chatTextField.text, text != "" {
            let message = Message(username: DBManager.me!.username, text: text)
            chatTextField.text = ""
            DBManager.sendMessage(message: message)
        } else {
            chatTextField.shake()
        }
    }
    
    deinit {
        print("ChatController: deinit")
    }
    
}

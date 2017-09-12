//
//  ChatController.swift
//  ContactsApp
//
//  Created by Sachin Ahuja on 9/10/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import UIKit
import SlackTextViewController

class ChatController: SLKTextViewController, DBManagerDelegate {
    
    override var tableView: UITableView {
        get { return super.tableView! }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ChatController")
        
        self.title = "\(DBManager.friends.count) people"
        self.isInverted = false
        self.tableView.separatorStyle = .none
        self.textView.placeholder = "Message"
        
        self.tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "MessageTableViewCell")
        DBManager.delegateChat = self
    }
    
    func dbManager(friendsUpdated count: Int) {
        self.title = "\(count) people"
    }
    
    func dbManager(messagesUpdated messages: [Message]) {
        print("ChatController: messagesUpdated", messages.count)
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DBManager.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell") as! MessageTableViewCell
        let message = DBManager.messages[(indexPath as NSIndexPath).row]
        
        cell.nameLabel.text = message.username
        cell.bodyLabel.text = message.text
        cell.selectionStyle = .none
        
        cell.transform = self.tableView.transform
        return cell
    }
    
    override func didPressRightButton(_ sender: Any!) {
        self.textView.refreshFirstResponder()
        let message = Message(username: DBManager.me!.username, text:  self.textView.text)
        DBManager.sendMessage(message: message)
        super.didPressRightButton(sender)
    }
    
    deinit {
        print("ChatController: deinit")
    }
    
}

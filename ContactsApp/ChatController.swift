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
    
    var ARButton: UIBarButtonItem = UIBarButtonItem()
    
    override var tableView: UITableView {
        get { return super.tableView! }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ChatController")
        
        self.title = "\(DBManager.friends.count) people"
        self.isInverted = false
        self.tableView.separatorStyle = .none
        self.shouldScrollToBottomAfterKeyboardShows = true
        self.textView.placeholder = "Message"
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 500.0
        self.tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "MessageTableViewCell")
        
        ARButton.title = "AR >"
        self.navigationItem.rightBarButtonItem = ARButton
        ARButton.target = self
        ARButton.action = #selector(ARButtonPressed)
        
        DBManager.delegateChat = self
    }
    
    @objc func ARButtonPressed(sender: UIButton!) {
        performSegue(withIdentifier: "goToAR", sender: self)
    }
    
    func dbManager(friendsUpdated count: Int) {
        self.title = "\(count) people"
    }
    
    func dbManager(messagesUpdated messages: [Message]) {
        print("ChatController: messagesUpdated", messages.count)
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: IndexPath(row: DBManager.messages.count - 1, section: 0), at: .top, animated: true)
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
        
        if message.userId == DBManager.me!.id {
            cell.nameLabel.textColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1.0)
            cell.nameLabel.textAlignment = .right
            cell.bodyLabel.textAlignment = .right
        } else {
            cell.nameLabel.textColor = UIColor(red: 0/255.0, green: 128/255.0, blue: 64/255.0, alpha: 1.0)
            cell.nameLabel.textAlignment = .left
            cell.bodyLabel.textAlignment = .left
        }
        
        cell.transform = self.tableView.transform
        return cell
    }
    
    override func didPressRightButton(_ sender: Any!) {
        self.textView.refreshFirstResponder()
        DBManager.sendMessage(text: self.textView.text)
        super.didPressRightButton(sender)
    }
    
    deinit {
        print("ChatController: deinit")
    }    
}

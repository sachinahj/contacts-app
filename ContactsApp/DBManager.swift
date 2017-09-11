//
//  DBManager.swift
//  ContactsApp
//
//  Created by Sachin Ahuja on 9/7/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import Foundation
import FirebaseDatabase
import GoogleMaps

protocol DBManagerDelegate: class {
    func dbManager(friendFound: Friend)
    func dbManager(friendLeft: Friend)
    func dbManager(friendsUpdated count: Int)
    func dbManager(messagesUpdated messages: [Message])
}

extension  DBManagerDelegate {
    func dbManager(friendFound: Friend) {}
    func dbManager(friendLeft: Friend) {}
    func dbManager(friendsUpdated count: Int) {}
    func dbManager(messagesUpdated messages: [Message]) {}
}

class DBManager {
    static var username: String?
    static var me: Me?
    static var friends: [Friend] = []
    static var messages: [Message] = []
    
    static var ref: DatabaseReference!
    static weak var delegateMap: DBManagerDelegate?
    static weak var delegateChat: DBManagerDelegate?
    
    
    static func createMe(username: String) {
        DBManager.me = Me(username: username)
    }
    
    static func updateMe(coordinate: CLLocationCoordinate2D) {
        DBManager.removeMe()
        DBManager.ref = Database.database().reference()
        
        let key = DBManager.ref.childByAutoId().key
        DBManager.me!.id = key
        DBManager.me!.coordinate = coordinate
        
        let updates = ["/users/\(DBManager.me!.id)": DBManager.me!.toJson()]
        DBManager.ref.updateChildValues(updates)
        
        DBManager.observe()
    }
    
    static func sendMessage(message: Message) {
        let key = DBManager.ref.childByAutoId().key
        var updates = ["/messages/\(DBManager.me!.id)/\(key)": message.toJson()]
        DBManager.friends.forEach { friend in updates["/messages/\(friend.id)/\(key)"] = message.toJson() }
        
        DBManager.ref = Database.database().reference()
        DBManager.ref.updateChildValues(updates)
    }
    
    static func removeMe() {
        DBManager.ref = Database.database().reference()
        if let me = DBManager.me, me.id != "" {
            DBManager.ref.child("users").child(me.id).removeValue()
            DBManager.ref.child("messages").child(me.id).removeValue()
        }
        DBManager.ref.child("users").removeAllObservers()
        DBManager.ref.child("messages").removeAllObservers()
        DBManager.friends = []
        DBManager.messages = []
    }
    
    static func observe() {
        DBManager.ref = Database.database().reference()
        DBManager.ref.child("users").observe(.childAdded, with: { snapshot in
            let friend = DBManager.getFriendFromSnapshot(snapshot: snapshot)
            guard let id = DBManager.me?.id, id != friend.id else { return }
            DBManager.friends.append(friend)
            DBManager.delegateMap?.dbManager(friendFound: friend)
            DBManager.delegateChat?.dbManager(friendsUpdated: DBManager.friends.count)
        })
        
        DBManager.ref.child("users").observe(.childRemoved, with: { snapshot in
            let _friend = DBManager.getFriendFromSnapshot(snapshot: snapshot)
            if let index = DBManager.friends.index(where: { f in f.id == _friend.id }) {
                let friend = DBManager.friends[index]
                DBManager.friends.remove(at: index)
                DBManager.delegateMap?.dbManager(friendLeft: friend)
                DBManager.delegateChat?.dbManager(friendsUpdated: DBManager.friends.count)
            }
        })
        
        DBManager.ref.child("messages").child(DBManager.me!.id).observe(.childAdded, with: { snapshot in
            let messageDict = snapshot.value as! [String : String]
            let message = Message(
                username: messageDict["username"]!,
                text: messageDict["text"]!
            )
            DBManager.messages.append(message)
            DBManager.delegateChat?.dbManager(messagesUpdated: DBManager.messages)
        })
    }
    
    private static func getFriendFromSnapshot(snapshot: DataSnapshot) -> Friend {
        let userDict = snapshot.value as! [String : String]
        
        let key = snapshot.key
        let username = userDict["username"]!
        let latitude = Double(userDict["latitude"]!)!
        let longitude = Double(userDict["longitude"]!)!
        
        let friend = Friend(
            id: key,
            username: username,
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        )
        
        return friend
    }
    
    deinit {
        print("DBManager: deinit")
    }
}


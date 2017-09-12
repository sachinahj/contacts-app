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
        me = Me(username: username)
    }
    
    static func updateMe(coordinate: CLLocationCoordinate2D) {
        ref = Database.database().reference()
        
        let key = ref.childByAutoId().key
        me!.id = key
        me!.coordinate = coordinate
        
        let updates = ["/users/\(me!.id)": me!.toJson()]
        ref.updateChildValues(updates)
    }
    
    static func removeMe() {
        ref = Database.database().reference()
        if let me = me, me.id != "" {
            ref.child("users").child(me.id).removeValue()
            ref.child("messages").child(me.id).removeValue()
        }
        ref.child("users").removeAllObservers()
        ref.child("messages").removeAllObservers()
        friends = []
        messages = []
    }
    
    static func sendMessage(text: String) {
        let key = ref.childByAutoId().key
        let message = Message(id: key, userId: DBManager.me!.id, username: DBManager.me!.username, text:  text)
        var updates = ["/messages/\(me!.id)/\(key)": message.toJson()]
        friends.forEach { friend in updates["/messages/\(friend.id)/\(key)"] = message.toJson() }
        ref = Database.database().reference()
        ref.updateChildValues(updates)
    }
    
    static func observe() {
        ref = Database.database().reference()
        ref.child("users").observe(.childAdded, with: { snapshot in
            let friend = getFriendFromSnapshot(snapshot: snapshot)
            guard let id = me?.id, id != friend.id else { return }
            if isFriendInRange(friend: friend) {
                friends.append(friend)
                delegateMap?.dbManager(friendFound: friend)
                delegateChat?.dbManager(friendsUpdated: friends.count)
            }
        })
        
        ref.child("users").observe(.childRemoved, with: { snapshot in
            let _friend = getFriendFromSnapshot(snapshot: snapshot)
            if let index = friends.index(where: { f in f.id == _friend.id }) {
                let friend = friends[index]
                friends.remove(at: index)
                delegateMap?.dbManager(friendLeft: friend)
                delegateChat?.dbManager(friendsUpdated: friends.count)
            }
        })
        
        ref.child("messages").child(me!.id).observe(.childAdded, with: { snapshot in
            let messageDict = snapshot.value as! [String : String]
            let message = Message(
                id: snapshot.key,
                userId: messageDict["userId"]!,
                username: messageDict["username"]!,
                text: messageDict["text"]!
            )
            messages.append(message)
            delegateChat?.dbManager(messagesUpdated: messages)
        })
    }
    
    private static func getFriendFromSnapshot(snapshot: DataSnapshot) -> Friend {
        let userDict = snapshot.value as! [String : String]
        let friend = Friend(
            id: snapshot.key,
            username: userDict["username"]!,
            coordinate: CLLocationCoordinate2D(latitude: Double(userDict["latitude"]!)!, longitude: Double(userDict["longitude"]!)!)
        )
        return friend
    }
    
    private static func isFriendInRange(friend: Friend) -> Bool {
        let lat1 = me!.coordinate.latitude.degreesToRadians
        let lon1 = me!.coordinate.longitude.degreesToRadians
        let lat2 = friend.coordinate.latitude.degreesToRadians
        let lon2 = friend.coordinate.longitude.degreesToRadians
        
        let latDelta = lat2 - lat1
        let lonDelta = lon2 - lon1
        
        let a = pow(sin(latDelta / 2), 2) + cos(lat1) * cos(lat2) *  pow(sin(lonDelta / 2), 2)
        let c = 2 * asin(min(1, sqrt(a)))
        let d = 6371000 * c
        
        return d <= 1000
    }
    
    deinit {
        print("DBManager: deinit")
    }
}


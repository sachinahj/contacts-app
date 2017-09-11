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
}

extension  DBManagerDelegate {
    func dbManager(friendFound: Friend) {}
    func dbManager(friendLeft: Friend) {}
    func dbManager(friendsUpdated count: Int) {}

}

class DBManager {
    static var username: String?
    static var me: Me?
    static var friends: [Friend] = []
    
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
        
        let updates = ["/\(DBManager.me!.id)": DBManager.me!.toJson()]
        DBManager.ref.updateChildValues(updates)
        
        DBManager.observe()
    }
    
    static func removeMe() {
        DBManager.ref = Database.database().reference()
        if let me = DBManager.me, me.id != "" { DBManager.ref.child(me.id).removeValue() }
        DBManager.ref.removeAllObservers()
        DBManager.friends = []
    }
    
    static func observe() {
        DBManager.ref = Database.database().reference()
        DBManager.ref.observe(.childAdded, with: { snapshot in
            let friend = DBManager.getFriendFromSnapshot(snapshot: snapshot)
            guard let id = DBManager.me?.id, id != friend.id else { return }
            DBManager.friends.append(friend)
            DBManager.delegateMap?.dbManager(friendFound: friend)
            DBManager.delegateChat?.dbManager(friendsUpdated: DBManager.friends.count)
        })
        
        DBManager.ref.observe(.childRemoved, with: { snapshot in
            let _friend = DBManager.getFriendFromSnapshot(snapshot: snapshot)
            if let index = DBManager.friends.index(where: { f in f.id == _friend.id }) {
                let friend = DBManager.friends[index]
                DBManager.friends.remove(at: index)
                DBManager.delegateMap?.dbManager(friendLeft: friend)
                DBManager.delegateChat?.dbManager(friendsUpdated: DBManager.friends.count)
            }
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


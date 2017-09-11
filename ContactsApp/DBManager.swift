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
    func dbManager(friendsUpdated: Int)
}

extension  DBManagerDelegate {
    func dbManager(friendFound: Friend) {}
    func dbManager(friendLeft: Friend) {}
    func dbManager(friendsUpdated: Int) {}

}

class DBManager {
    static var username: String?
    static var me: Me?
    static var friends: [Friend] = []
    
    var ref: DatabaseReference!
    weak var delegate: DBManagerDelegate?
    
    func createMe(username: String) {
        DBManager.me = Me(username: username)
    }
    
    func updateMe(coordinate: CLLocationCoordinate2D) {
        removeMe()
        ref = Database.database().reference()
        
        let key = ref.childByAutoId().key
        DBManager.me!.id = key
        DBManager.me!.coordinate = coordinate
        
        let updates = ["/\(DBManager.me!.id)": DBManager.me!.toJson()]
        ref.updateChildValues(updates)
        
        observe()
    }
    
    func removeMe() {
        ref = Database.database().reference()
        if let me = DBManager.me, me.id != "" { ref.child(me.id).removeValue() }
        ref.removeAllObservers()
        DBManager.friends = []
    }
    
    func observe() {
        ref = Database.database().reference()
        ref.observe(.childAdded, with: { snapshot in
            let friend = self.getFriendFromSnapshot(snapshot: snapshot)
            guard let id = DBManager.me?.id, id != friend.id else { return }
            DBManager.friends.append(friend)
            self.delegate?.dbManager(friendFound: friend)
            self.delegate?.dbManager(friendsUpdated: 1)
            print("DBManager: friendFound", friend)
        })
        
        ref.observe(.childRemoved, with: { snapshot in
            let _friend = self.getFriendFromSnapshot(snapshot: snapshot)
            if let index = DBManager.friends.index(where: { f in f.id == _friend.id }) {
                let friend = DBManager.friends[index]
                DBManager.friends.remove(at: index)
                self.delegate?.dbManager(friendLeft: friend)
                self.delegate?.dbManager(friendsUpdated: 0)
                print("DBManager: friendLeft", friend)
            }
        })
    }
    
    private func getFriendFromSnapshot(snapshot: DataSnapshot) -> Friend {
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


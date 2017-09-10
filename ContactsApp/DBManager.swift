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

protocol DBManagerDelegate: NSObjectProtocol {
    func dbManager(friendFound: Friend)
    func dbManager(friendLeft: Friend)
}

class DBManager {
    static var username: String?
    static var me: Me?
    
    var ref: DatabaseReference!
    weak var delegate: DBManagerDelegate?
    
    func createMe(username: String) {
        DBManager.me = Me(username: username)
    }
    
    func updateMe(coordinate: CLLocationCoordinate2D) -> Me {
        removeMe()
        ref = Database.database().reference()
        
        let key = ref.childByAutoId().key
        DBManager.me!.id = key
        DBManager.me!.coordinate = coordinate
        
        let updates = ["/\(DBManager.me!.id)": DBManager.me!.toJson()]
        ref.updateChildValues(updates)
        
        observe()
        
        return DBManager.me!
    }
    
    func removeMe() {
        ref = Database.database().reference()
        ref.removeAllObservers()
        if let me = DBManager.me, me.id != "" {
            ref.child(me.id).removeValue()
        }
    }
    
    func observe() {
        ref = Database.database().reference()
        ref.observe(.childAdded, with: { snapshot in
            let friend = self.getFriendFromSnapshot(snapshot: snapshot)
            self.delegate?.dbManager(friendFound: friend)
        })
        
        ref.observe(.childRemoved, with: { snapshot in
            let friend = self.getFriendFromSnapshot(snapshot: snapshot)
            self.delegate?.dbManager(friendLeft: friend)
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


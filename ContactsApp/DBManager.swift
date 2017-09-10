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

protocol DBManagerDelegate {
    func dbManager(friendFound: User)
    func dbManager(friendLeft: User)
}

class DBManager {
    
    var ref: DatabaseReference!
    var delegate: DBManagerDelegate?
    var me: User?
    
    func updateMe(username: String, coordinate: CLLocationCoordinate2D) -> User {
        removeMe()
        
        ref = Database.database().reference()
        let key = ref.childByAutoId().key
        let _me = User(id: key, username: username, coordinate: coordinate)
        
        let updates = ["/\(_me.id)": _me.toJson()]
        ref.updateChildValues(updates)
        
        observe()
        
        me = _me
        return me!
    }
    
    func removeMe() {
        ref = Database.database().reference()
        ref.removeAllObservers()
        
        print("DBManager: me", me)
        if let _me = me {
            ref.child(_me.id).removeValue()
        }
    }
    
    func observe() {
        ref = Database.database().reference()
        ref.observe(.childAdded, with: { snapshot in
            let friend = self.getUserFromSnapshot(snapshot: snapshot)
            self.delegate?.dbManager(friendFound: friend)
        })
        
        ref.observe(.childRemoved, with: { snapshot in
            let friend = self.getUserFromSnapshot(snapshot: snapshot)
            self.delegate?.dbManager(friendLeft: friend)
        })
    }
    
    private func getUserFromSnapshot(snapshot: DataSnapshot) -> User {
        let userDict = snapshot.value as! [String : String]
        let latitude = Double(userDict["latitude"]!)!
        let longitude = Double(userDict["longitude"]!)!
        let user = User(
            id: snapshot.key,
            username: userDict["username"]!,
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        )
        return user
    }
}


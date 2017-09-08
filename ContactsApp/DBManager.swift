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

protocol UserDelegate {
    func friendFound(friend: User)
    func friendLeft(friend: User)
}

class DBManager {
    
    var ref: DatabaseReference!
    var delegate: UserDelegate?
    var me: User?
    
    func updateMe(username: String, coordinate: CLLocationCoordinate2D) -> User {
        removeMe()
        
        ref = Database.database().reference()
        let key = ref.childByAutoId().key
        let user = User(key: key, username: username, coordinate: coordinate)
        
        let updates = ["/\(user.key)": user.toJson()]
        ref.updateChildValues(updates)
        
        observe()
        
        me = user
        return me!
    }
    
    func removeMe() {
        ref = Database.database().reference()
        ref.removeAllObservers()
        
        if let _me = me {
            ref.child(_me.key).removeValue()
        }
    }
    
    func observe() {
        ref = Database.database().reference()
        ref.observe(.childAdded, with: { snapshot in
            let friend = self.getUserFromSnapshot(snapshot: snapshot)
            self.delegate?.friendFound(friend: friend)
        })
        
        ref.observe(.childRemoved, with: { snapshot in
            let friend = self.getUserFromSnapshot(snapshot: snapshot)
            self.delegate?.friendLeft(friend: friend)
        })
    }
    
    private func getUserFromSnapshot(snapshot: DataSnapshot) -> User {
        let userDict = snapshot.value as! [String : String]
        let latitude = Double(userDict["latitude"]!)!
        let longitude = Double(userDict["longitude"]!)!
        let user = User(
            key: snapshot.key,
            username: userDict["username"]!,
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        )
        return user
    }
}


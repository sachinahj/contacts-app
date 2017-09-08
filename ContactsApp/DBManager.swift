//
//  DBManager.swift
//  ContactsApp
//
//  Created by Sachin Ahuja on 9/7/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import Foundation
import FirebaseDatabase

fileprivate let ref: DatabaseReference = Database.database().reference()
fileprivate var key: String?
fileprivate var peeps = [User]()

class DBManager {
    
    static func addUser(username: String, latitude: Double, longitude: Double) {
        removeUser()
        
        let user = User(username: username, latitude: latitude, longitude: longitude)
        key = ref.childByAutoId().key
        
        let updates = ["/\(key!)": user.toJson()]
        ref.updateChildValues(updates)
    }
    
    static func removeUser() {
        if let _key = key {
            ref.child(_key).removeValue()
        }
    }
    
    static func observePeeps() {
        ref.removeAllObservers()
        peeps = [User]()
        
        ref.observe(.childAdded, with: { snapshot in
            let userDict = snapshot.value as! [String : String]
            let user = User(
                username: userDict["username"]!,
                latitude: Double(userDict["latitude"]!)!,
                longitude: Double(userDict["longitude"]!)!
            )
            user.key = snapshot.key
            print("added", user, user.key!)
            peeps.append(user)
        })
        
        ref.observe(.childRemoved, with: { snapshot in
            let userDict = snapshot.value as! [String : String]
            print("removed", userDict)
        })
    }
}

class User {
    var key: String?
    var username: String!
    var latitude: Double!
    var longitude: Double!
    
    init(username: String, latitude: Double, longitude: Double) {
        self.username = username
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func toJson() -> [String: String] {
        return ["username": self.username,
                "latitude": String(self.latitude),
                "longitude": String(self.longitude)]
    }
}

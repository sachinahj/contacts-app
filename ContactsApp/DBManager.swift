//
//  DBManager.swift
//  ContactsApp
//
//  Created by Sachin Ahuja on 9/7/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import Foundation
import FirebaseDatabase

fileprivate var key: String?
fileprivate var ref: DatabaseReference!

class DBManager {
    
    static func addUser(username: String, latitude: Double, longitude: Double) {
        removeUser()
        ref = Database.database().reference()
        key = ref.childByAutoId().key
        let user = ["username": username,
                    "latitude": String(latitude),
                    "longitude": String(longitude)]
        let updates = ["/\(key!)": user]
        ref.updateChildValues(updates)
    }
    
    static func removeUser() {
        if let _key = key {
            ref = Database.database().reference()
            ref.child(_key).removeValue()
        }
    }
}

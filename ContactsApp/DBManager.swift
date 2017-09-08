//
//  DBManager.swift
//  ContactsApp
//
//  Created by Sachin Ahuja on 9/7/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import Foundation
import Firebase

fileprivate let ref: DatabaseReference = Database.database().reference()
fileprivate var key: String?

class DBManager {
    
    static func addUser(username: String, latitude: Double, longitude: Double) {
        removeUser()
        key = ref.childByAutoId().key
        let user = ["username": username,
                    "latitude": String(latitude),
                    "longitude": String(longitude)]
        let updates = ["/\(key!)": user]
        ref.updateChildValues(updates)
    }
    
    static func removeUser() {
        if let _key = key {
            ref.child(_key).removeValue()
        }
    }
}

//
//  DBManager.swift
//  ContactsApp
//
//  Created by Sachin Ahuja on 9/7/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import Foundation
import Firebase


class DBManager {
    
    let ref: DatabaseReference = Database.database().reference()
    var key: String = ""
    
    func addUser(username: String, latitude: Double, longitude: Double) {
        key = ref.child("posts").childByAutoId().key
        let user = ["username": username,
                    "latitude": String(latitude),
                    "longitude": String(longitude)]
        let updates = ["/\(key)": user]
        ref.updateChildValues(updates)
    }
}

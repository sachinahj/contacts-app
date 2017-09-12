//
//  Message.swift
//  ContactsApp
//
//  Created by Atom - Sachin on 9/11/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import Foundation

class Message {
    var id: String
    var userId: String
    var username: String
    var text: String
    
    init(id: String, userId: String, username: String, text: String) {
        self.id = id
        self.userId = userId
        self.username = username
        self.text = text
    }
    
    func toJson() -> [String: String] {
        return [
            "userId" : self.userId,
            "username" : self.username,
            "text": self.text
        ]
    }
}

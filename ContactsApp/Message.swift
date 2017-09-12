//
//  Message.swift
//  ContactsApp
//
//  Created by Atom - Sachin on 9/11/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import Foundation

class Message {
    let id: String!
    let username: String!
    let text: String!
    
    init(id: String, username: String, text: String) {
        self.id = id
        self.username = username
        self.text = text
    }
    
    func toJson() -> [String: String] {
        return [
            "id" : self.id,
            "username" : self.username,
            "text": self.text
        ]
    }
}

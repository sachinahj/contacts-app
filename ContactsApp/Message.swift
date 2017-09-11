//
//  Message.swift
//  ContactsApp
//
//  Created by Atom - Sachin on 9/11/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import Foundation

class Message {
    let username: String!
    let text: String!
    
    init(username: String, text: String) {
        self.username = username
        self.text = text
    }
    
    func toJson() -> [String: String] {
        return ["username" : self.username, "text": self.text]
    }
}

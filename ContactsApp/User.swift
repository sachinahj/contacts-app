//
//  User.swift
//  ContactsApp
//
//  Created by Sachin Ahuja on 9/8/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import Foundation
import GoogleMaps

class User {
    var key: String
    var username: String
    var coordinate: CLLocationCoordinate2D
    var marker: GMSCircle?
    var range: GMSCircle?
    
    init(key: String, username: String, coordinate: CLLocationCoordinate2D) {
        self.key = key
        self.username = username
        self.coordinate = coordinate
    }
    
    func toJson() -> [String: String] {
        return ["username": self.username,
                "latitude": String(self.coordinate.latitude),
                "longitude": String(self.coordinate.longitude)]
    }
}

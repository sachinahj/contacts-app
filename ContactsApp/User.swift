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
    var id: String
    var username: String
    var coordinate: CLLocationCoordinate2D
    var marker: GMSCircle?
    var range: GMSCircle?
    
    init(id: String, username: String, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.username = username
        self.coordinate = coordinate
    }
    
    func toJson() -> [String: String] {
        return ["username": self.username,
                "latitude": String(self.coordinate.latitude),
                "longitude": String(self.coordinate.longitude)]
    }
}

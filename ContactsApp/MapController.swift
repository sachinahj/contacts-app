//
//  ViewController.swift
//  contacts
//
//  Created by Sachin Ahuja on 9/3/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import UIKit
import GoogleMaps

class MapController: UIViewController, GMSMapViewDelegate, DBManagerDelegate {
    
    var dbManager: DBManager!
    
    var mapView: GMSMapView!
    var myLocationFound: Bool!
    
    var username: String!
    var me: User?
    var friends: [User] = []
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.title = "Loading..."
            } else {
                self.title = "Tap Hangout Location"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MapController", username)
        
        self.title = "Tap Hangout Location"
        
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 1.0)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        myLocationFound = false
        mapView.delegate = self
        
        dbManager = DBManager()
        dbManager.delegate = self
        
        view = mapView
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if isLoading == false {
            isLoading = true
            resetFriends()
            let me = dbManager.updateMe(username: username, coordinate: coordinate)
            markMe(me: me)
        }
    }
    
    func dbManager(friendFound: User) {
        guard let id = me?.id, id != friendFound.id else { return }
        markFriend(friend: friendFound)
        friends.append(friendFound)
    }
    
    func dbManager(friendLeft: User) {
        print("friendLeft", friendLeft)
        if let index = friends.index(where: { friend in friend.id == friendLeft.id }) {
            friends[index].marker?.map = nil
        }
    }
    
    func markMe(me user: User) {
        me?.marker?.map = nil
        me?.range?.map = nil
        markUser(user: user, color: UIColor.blue)
        markUserRange(user: user, color: UIColor.blue)
        me = user
    }
    
    func markFriend(friend user: User) {
        markUser(user: user, color: UIColor.red)
    }
    
    func resetFriends() {
        friends.forEach({ friend in friend.marker?.map = nil })
        friends = []
    }
    
    func markUser(user: User, color: UIColor) {
        animateUserMarker(coordinate: user.coordinate, delayMultiplier: 0.05, radiusMultiplier: 2.5, strokeColor: color, fillColor: color, completion: { marker in user.marker = marker })
    }
    
    func markUserRange(user: User, color: UIColor) {
        animateUserMarker(coordinate: user.coordinate, delayMultiplier: 0.1, radiusMultiplier: 100, strokeColor: color, fillColor: nil, completion: { marker in
            user.range = marker
            self.isLoading = false
        })
    }
    
    func animateUserMarker(coordinate: CLLocationCoordinate2D, delayMultiplier: Double, radiusMultiplier: Double, strokeColor: UIColor, fillColor: UIColor?, completion: ((GMSCircle) -> Void)?) {
        var marker: GMSCircle?
        
        for i in 1...10 {
            let delay = Double(i) * delayMultiplier
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let radius = Double(i) * radiusMultiplier
                marker?.map = nil
                marker = GMSCircle(position: coordinate, radius: radius)
                marker!.strokeColor = strokeColor
                if let color = fillColor { marker!.fillColor = color }
                marker!.map = self.mapView
                
                if i == 10 {
                    if let _completion = completion { _completion(marker!) }
                }
            }
        }
    }

    func removeMyLocationObserver() {
        if myLocationFound == false {
            myLocationFound = true
            mapView.removeObserver(self, forKeyPath: "myLocation")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let update = change, let myLocation = update[NSKeyValueChangeKey.newKey] as? CLLocation else { return }
        mapView.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 15.0)
        removeMyLocationObserver()
    }
    
    deinit {
        dbManager.removeMe()
        removeMyLocationObserver()
    }
    
}


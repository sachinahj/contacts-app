//
//  ViewController.swift
//  contacts
//
//  Created by Sachin Ahuja on 9/3/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import UIKit
import GoogleMaps

class MapController: UIViewController, GMSMapViewDelegate, UserDelegate {
    
    let dbManager: DBManager = DBManager()
    var username: String!
    
    var mapView: GMSMapView!
    var myLocationFound: Bool!
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
        dbManager.delegate = self
        
        view = mapView
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("tap at", coordinate.latitude, coordinate.longitude)
        if isLoading == false {
            isLoading = true
            let me = dbManager.updateMe(username: username, coordinate: coordinate)
            markMe(me: me)
            print("===========", me.key)
        }
    }
    
    func friendFound(friend: User) {
        print("friend.key", friend.key)
        guard let meKey = me?.key, meKey != friend.key else {
            return
        }
    
        let marker = GMSCircle(position: friend.coordinate, radius: 25)
        marker.strokeColor = UIColor.red
        marker.fillColor = UIColor.red
        marker.map = mapView
    
        friend.marker = marker
        friends.append(friend)
    }
    
    
    func friendLeft(friend: User) {
        print("friendLeft", friend)
    }
    
    func markMe(me user: User) {
        me?.marker?.map = nil
        me?.range?.map = nil
        
        let marker = GMSCircle(position: user.coordinate, radius: 25)
        marker.strokeColor = UIColor.blue
        marker.fillColor = UIColor.blue
        marker.map = mapView
        
        user.marker = marker
        me = user
        
        for i in 1...10 {
            let delay = Double(i) * 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let radius = Double(i) * 100
                self.me!.range?.map = nil
                self.me!.range = GMSCircle(position: user.coordinate, radius: radius)
                self.me!.range!.strokeColor = UIColor.black
                self.me!.range!.map = self.mapView
                
                if i == 10 {
                    self.isLoading = false
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


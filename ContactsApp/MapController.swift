//
//  ViewController.swift
//  contacts
//
//  Created by Sachin Ahuja on 9/3/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import UIKit
import GoogleMaps

class MapController: UIViewController, GMSMapViewDelegate {
    
    var username: String!
    
    var mapView: GMSMapView!
    var myLocationFound: Bool!
    var me: GMSCircle?
    var meRange: GMSCircle?
    
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
        
        mapView.delegate = self
        
        // https://stackoverflow.com/questions/40986708/google-maps-start-at-user-location
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        myLocationFound = false
        
        view = mapView
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("tap at", coordinate.latitude, coordinate.longitude)
        if isLoading == false {
            isLoading = true
            markCircle(atCoordinate: coordinate)
            DBManager.addUser(username: username, latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }
    
    func markCircle(atCoordinate coordinate: CLLocationCoordinate2D) {
        me?.map = nil
        me = GMSCircle(position: coordinate, radius: 25)
        me!.strokeColor = UIColor.black
        me!.fillColor = UIColor.black
        me!.map = mapView
        
        for i in 1...10 {
            let delay = Double(i) * 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let radius = Double(i) * 100
                self.meRange?.map = nil
                self.meRange = GMSCircle(position: coordinate, radius: radius)
                self.meRange!.strokeColor = UIColor.black
                self.meRange!.map = self.mapView
                
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
        DBManager.removeUser()
        removeMyLocationObserver()
    }
    
}


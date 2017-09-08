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
    
    var isLoading: Bool = false
    
    var username: String!
    
    var mapView: GMSMapView!
    var myLocationFound: Bool!
    var me: GMSCircle?
    var meRange: GMSCircle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MapController", username)
        
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
        if (!isLoading) {
            isLoading = true
            markCircle(atCoordinate: coordinate)
            DBManager.addUser(username: username, latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }
    
    func markCircle(atCoordinate coordinate: CLLocationCoordinate2D) {
        me?.map = nil
        meRange?.map = nil
        
        me = GMSCircle(position: coordinate, radius: 25)
        meRange = GMSCircle(position: coordinate, radius: 1000)
        
        me?.strokeColor = UIColor.black
        me?.fillColor = UIColor.black
        meRange?.strokeColor = UIColor.black
        
        me?.map = mapView
        meRange?.map = mapView
    }
    
    func removeMyLocationObserver() {
        if (myLocationFound == false) {
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


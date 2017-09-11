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
    
    var mapView: GMSMapView!
    var myLocationFound: Bool!
    var chatButton: UIBarButtonItem = UIBarButtonItem()
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.title = "Loading..."
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            } else {
                self.title = "Tap Hangout Location"
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MapController")
        
        self.title = "Tap Hangout Location"
        self.navigationItem.rightBarButtonItem = nil
        
        chatButton.target = self
        chatButton.action = #selector(chatButtonPressed)
        
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 1.0)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        myLocationFound = false
        
        mapView.delegate = self
        DBManager.delegateMap = self
        
        view = mapView
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if isLoading == false {
            isLoading = true
            
            DBManager.friends.forEach({ friend in friend.marker?.map = nil })
            DBManager.me!.marker?.map = nil
            DBManager.me!.range?.map = nil
            
            DBManager.updateMe(coordinate: coordinate)
            markUser(user: DBManager.me!, color: UIColor.black)
            markRange(me: DBManager.me!, color: UIColor.black, completion: {_ in self.isLoading = false })
        }
    }
    
    func dbManager(friendFound: Friend) {
        print("MapController: friendFound")
        markUser(user: friendFound, color: UIColor.red)
        updateChatCount()
    }
    
    func dbManager(friendLeft: Friend) {
        print("MapController: friendLeft")
        friendLeft.marker?.map = nil
        updateChatCount()
    }
    
    func updateChatCount() {
        chatButton.title = "Chat (\(DBManager.friends.count)) >"
        if DBManager.friends.count > 0 {
            self.navigationItem.rightBarButtonItem = chatButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func chatButtonPressed(sender: UIButton!) {
        performSegue(withIdentifier: "goToChat", sender: self)
    }
    
    func markUser(user: User, color: UIColor) {
        let timeline = [(0.05, 5.0),(0.1, 10.0),(0.15, 15.0),(0.2, 20.0),(0.25, 25.0),(0.3, 20.0),(0.35, 15.0),(0.4, 10.0),(0.45, 15.0),(0.5, 25.0)]
        animateMarker(coordinate: user.coordinate, timeline: timeline, strokeColor: color, fillColor: color, completion: { marker in
            user.marker = marker
        })
    }
    
    func markRange(me: Me, color: UIColor, completion: @escaping () -> Void) {
        let timeline = [(0.1, 100.0),(0.1, 200.0),(0.3, 300.0),(0.4, 400.0),(0.5, 500.0),(0.6, 600.0),(0.7, 700.0),(0.8, 800.0),(0.9, 900.0),(1.0, 1000.0)]
        animateMarker(coordinate: me.coordinate, timeline: timeline, strokeColor: color, fillColor: nil, completion: { marker in
            me.range = marker
            completion()
        })
    }
    
    func animateMarker(coordinate: CLLocationCoordinate2D, timeline: [(Double, Double)], strokeColor: UIColor, fillColor: UIColor?, completion: @escaping (GMSCircle) -> Void) {
        var marker: GMSCircle?
        
        for i in 0..<timeline.count {
            let delay = timeline[i].0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let radius = timeline[i].1
                marker?.map = nil
                marker = GMSCircle(position: coordinate, radius: radius)
                marker!.strokeColor = strokeColor
                if let color = fillColor { marker!.fillColor = color }
                marker!.map = self.mapView
                
                if i == timeline.count - 1 { completion(marker!) }
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
        print("MapController: deinit")
        DBManager.removeMe()
        removeMyLocationObserver()
    }
    
}

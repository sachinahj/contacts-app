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
                self.navigationItem.rightBarButtonItem = chatButton
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
            DBManager.removeMe()
            DBManager.updateMe(coordinate: coordinate)
            markUser(user: DBManager.me!, color: UIColor.black)
            markRange(me: DBManager.me!, color: UIColor.black, completion: {
                self.isLoading = false
                self.updateChatCount()
                DBManager.observe()
            })
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
    }
    
    @objc func chatButtonPressed(sender: UIButton!) {
        performSegue(withIdentifier: "goToChat", sender: self)
    }
    
    func markUser(user: User, color: UIColor) {
        let timeline = [(0.05, 5.0),(0.1, 10.0),(0.15, 15.0),(0.2, 20.0),(0.25, 25.0),(0.3, 20.0),(0.35, 15.0),(0.4, 10.0),(0.45, 15.0),(0.5, 25.0)]
        animateMarker(coordinate: user.coordinate, timeline: timeline, strokeColor: color, fillColor: color, completion: { marker in
            user.marker = marker
        })
    }
    
    func markRange(me: Me, color: UIColor, completion: @escaping () -> Void) {
        let timeline = [(0.025, 25.0),(0.050, 50.0),(0.075, 75.0),(0.100, 100.0),(0.125, 125.0),(0.150, 150.0),(0.175, 175.0),(0.200, 200.0),(0.225, 225.0),(0.250, 250.0),(0.275, 275.0),(0.300, 300.0),(0.325, 325.0),(0.350, 350.0),(0.375, 375.0),(0.400, 400.0),(0.425, 425.0),(0.450, 450.0),(0.475, 475.0),(0.500, 500.0),(0.525, 525.0),(0.550, 550.0),(0.575, 575.0),(0.600, 600.0),(0.625, 625.0),(0.650, 650.0),(0.675, 675.0),(0.700, 700.0),(0.725, 725.0),(0.750, 750.0),(0.775, 775.0),(0.800, 800.0),(0.825, 825.0),(0.850, 850.0),(0.875, 875.0),(0.900, 900.0),(0.925, 925.0),(0.950, 950.0),(0.975, 975.0),(1.000, 1000.0)]
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

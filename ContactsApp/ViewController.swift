//
//  ViewController.swift
//  contacts
//
//  Created by Sachin Ahuja on 9/3/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import UIKit
import Contacts
import GoogleMaps

class ViewController: UIViewController {
    
//    let contactsManager = ContactsManager()
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?

    var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 1.0)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        view = mapView
        
        view.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)

        
//        contactsManager.get(completion: {
//            (contacts) in
//            self.getCoordinates(contacts: contacts)
//        })
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let update = change, let myLocation = update[NSKeyValueChangeKey.newKey] as? CLLocation else {
            return
        }
        self.mapView.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 15.0)
    }
    
//    func getCoordinates(contacts: [CNContact]) {
//        contacts.forEach { contact in
//            let label = CNLabeledValue<NSString>.localizedString(forLabel: ("\(contact.givenName) \(contact.familyName)"))
//            
//            contact.postalAddresses.forEach { address in
//                let addy = "\(address.value.street), \(address.value.city), \(address.value.state) \(address.value.postalCode)"
//                
//                print(label)
//                CLGeocoder().geocodeAddressString(addy, completionHandler: { (placemarks, error) in
//                    print("done", label, addy)
//                
//                    if let placemark = placemarks?.first {
//                        let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
//                        
//                        print("lat \(coordinates.latitude)")
//                        print("long \(coordinates.longitude)")
//                        self.placeMarker(label: label, coordinates: coordinates)
//                    }
//                })
//            }
//        }
//    }
//    
//    func placeMarker(label: String, coordinates: CLLocationCoordinate2D) {
//        let position = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
//        let marker = GMSMarker(position: position)
//        marker.title = label
//        marker.map = mapView
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        locationManager.stopUpdatingLocation()
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15.0)
        mapView.camera = camera
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}


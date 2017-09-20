//
//  ARController.swift
//  ContactsApp
//
//  Created by Atom - Sachin on 9/19/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import UIKit
import ARCL
import CoreLocation

class ARController: UIViewController {
    var sceneLocationView = SceneLocationView()

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        DBManager.friends.forEach {friend in
            let location = CLLocation(coordinate: friend.coordinate, altitude: 50)
            let image = UIImage(named: "pin")!
            let annotationNode = LocationAnnotationNode(location: location, image: image)
            annotationNode.scaleRelativeToDistance = false
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = view.bounds
    }
    
    deinit {
        print("ARController: deinit")
        sceneLocationView.pause()
    }
}

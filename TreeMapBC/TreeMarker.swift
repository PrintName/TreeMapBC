//
//  TreeMarker.swift
//  TreeMapBC
//
//  Created by Allen on 09/07/2019.
//  Copyright © 2019 Allen+Megan. All rights reserved.
//

import Foundation
import MapKit

class TreeMarkerView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let tree = newValue as? Tree else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: 0, y: 0)
            if let imageName = tree.imageName {
                image = UIImage(named: imageName)
            }
            else {
                image = nil
            }
            let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 35, height: 35)))
            button.setBackgroundImage(UIImage(named: "Button"), for: UIControl.State())
            rightCalloutAccessoryView = button
        }
    }
}


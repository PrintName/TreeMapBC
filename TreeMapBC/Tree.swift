//
//  Tree.swift
//  TreeMapBC
//
//  Created by Allen on 04/07/2019.
//  Copyright © 2019 Allen+Megan. All rights reserved.
//

import Foundation
import MapKit

class Tree: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let detail: [String]
    
    init(title: String, detail: [String], coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.detail = detail
        self.coordinate = coordinate
        super.init()
    }
    
    var subtitle: String? {
        return detail[4]
    }    
    
    var imageName: String? {
        let botanicalName = detail[4]
        let dbh = Int(detail[6])!
        if dbh <= 10 {
            if botanicalName == "Tilia cordata" { return "GoldMarker20" }
            return "Marker20"
        }
        if dbh <= 30 {
            if botanicalName == "Tilia cordata" { return "GoldMarker30" }
            return "Marker30"
        }
        if botanicalName == "Tilia cordata" { return "GoldMarker40" }
        return "Marker40"
    }
    
}

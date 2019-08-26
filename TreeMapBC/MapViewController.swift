//
//  MapViewController.swift
//  TreeMapBC
//
//  Created by Allen on 04/07/2019.
//  Copyright © 2019 Allen+Megan. All rights reserved.
//

import UIKit
import MapKit
import PMAlertController
import CFAlertViewController

class ViewController: UIViewController, dataProtocal {
    
    // White status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var mapView: MKMapView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up map
        mapView.mapType = MKMapType.satellite
        mapView.delegate = self
      
        // Set initial map view
        let initialLocation = CLLocation(latitude: 42.3361, longitude: -71.1677)
        let initialRegion = MKCoordinateRegion(center: initialLocation.coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(initialRegion, animated: true)
         
        // Set up markers
        mapView.register(TreeMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

        // Populate map with Tree Array
        mapView.addAnnotations(treeData.array)
      
         // Button to toggle user tracking behavior
         let userTrackingButton = MKUserTrackingButton(mapView: mapView)
         userTrackingButton.tintColor = UIColor.white
         userTrackingButton.layer.backgroundColor = UIColor(red: 0.0/255.0, green: 52.0/255.0, blue: 9.0/255.0, alpha: 1.0).cgColor
         userTrackingButton.layer.borderWidth = 1
         userTrackingButton.layer.cornerRadius = 5
         userTrackingButton.layer.borderColor = UIColor.white.cgColor
         userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(userTrackingButton)
         let safeArea = view.safeAreaLayoutGuide
         NSLayoutConstraint.activate([userTrackingButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10), userTrackingButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10)])
      
    }
   
    // Show user location
    let userLocationManager = CLLocationManager()
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            mapView.userLocation.title = ""
        }
        else {
            userLocationManager.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
            mapView.userLocation.title = ""
        }
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore {
           // Show tutorial if never launched before
           performSegue(withIdentifier: "helpSegue", sender: nil)
           UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
      
        checkLocationAuthorizationStatus()
      
    }
   
    // Set up saved annotations for map height based removal
    var smallAnnotations = treeData.array.filter { Int($0.detail[6])! <= 10 }
    var mediumAnnotations = treeData.array.filter { Int($0.detail[6])! > 10 && Int($0.detail[6])! <= 30 }
    var textFiltered = false
   
    var oldFilterData : [String:String] = [:]
   
    // Delegate
    func sendData(filterData: [String:String]) {
      
        oldFilterData = filterData
        // Remove markers
        mapView.removeAnnotations(mapView.annotations)
        // Repopulate map with filtered tree array
        let filteredTreeArray = filterArray(originalTreeArray: treeData.array, filterData: filterData)
        mapView.addAnnotations(filteredTreeArray)
      
        // Update saved annotations for map height based removal
        smallAnnotations = filteredTreeArray.filter { Int($0.detail[6])! <= 10 }
        mediumAnnotations = filteredTreeArray.filter { Int($0.detail[6])! > 10 && Int($0.detail[6])! <= 30 }
        // If user filtered by Common Name, Botanical Name, Tag, or Diameter: Do not remove annotations
        if !filterData["commonNameText"]!.isEmpty || !filterData["botanicalNameText"]!.isEmpty || !filterData["tagLowText"]!.isEmpty || !filterData["tagHighText"]!.isEmpty || !filterData["diameterLowText"]!.isEmpty || !filterData["diameterHighText"]!.isEmpty {
           textFiltered = true
        }
        else {
           textFiltered = false
        }
        // Filtered height based removal
        if textFiltered == false {
           if (self.mapView.region.span.latitudeDelta > 0.0018) {
              mapView.removeAnnotations(smallAnnotations)
              small.backgroundColor = UIColor(red: 0.0/255.0, green: 52.0/255.0, blue: 9.0/255.0, alpha: 1.0)
              small.setTitleColor(UIColor.white, for: .normal)
           }
           if (self.mapView.region.span.latitudeDelta > 0.004) {
              mapView.removeAnnotations(mediumAnnotations)
              medium.backgroundColor = UIColor(red: 0.0/255.0, green: 52.0/255.0, blue: 9.0/255.0, alpha: 1.0)
              medium.setTitleColor(UIColor.white, for: .normal)
           }
        }
        else {
           small.backgroundColor = UIColor.white
           small.setTitleColor(UIColor(red: 0.0/255.0, green: 52.0/255.0, blue: 9.0/255.0, alpha: 1.0), for: .normal)
           medium.backgroundColor = UIColor.white
           medium.setTitleColor(UIColor(red: 0.0/255.0, green: 52.0/255.0, blue: 9.0/255.0, alpha: 1.0), for: .normal)
        }
      
    }
    
    // Segue prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filterSegue" {
            let DestViewController = segue.destination as! UINavigationController
            let filterView = DestViewController.topViewController as! FilterViewController
            filterView.delegate = self
            filterView.oldFilterData = oldFilterData
        }
    }
   
   @IBAction func impactButton(_ sender: Any) {
      if filteredImpact.data.count == 0 {
         let alertController = CFAlertViewController(title: "Total Annual Impact", titleColor: UIColor(red: 0.0/255.0, green: 52.0/255.0, blue: 9.0/255.0, alpha: 1.0), message: "CO2 Offset: 111,349 lb / 275,589 mi driven \n Total Carbon Stored: 5,141,018 lb \n Air Pollution Removed: 39,785 oz \n Rainfall Runoff Intercepted: 521,983 gal", messageColor: UIColor.black, textAlignment: .center, preferredStyle: CFAlertViewController.CFAlertControllerStyle.alert, headerView: nil, footerView: nil, didDismissAlertHandler: nil)
         present(alertController, animated: true, completion: nil)
      }
      else {
         let alertController = CFAlertViewController(title: "Filtered Annual Impact", titleColor: UIColor(red: 0.0/255.0, green: 52.0/255.0, blue: 9.0/255.0, alpha: 1.0), message: "CO2 Offset: \(filteredImpact.data[0]) lb / \(filteredImpact.data[1]) mi driven \n Total Carbon Stored: \(filteredImpact.data[2]) lb \n Air Pollution Removed: \(filteredImpact.data[3]) oz \n Rainfall Runoff Intercepted: \(filteredImpact.data[4]) gal", messageColor: UIColor.black, textAlignment: .center, preferredStyle: CFAlertViewController.CFAlertControllerStyle.alert, headerView: nil, footerView: nil, didDismissAlertHandler: nil)
         present(alertController, animated: true, completion: nil)
      }
    }
    
    @IBOutlet weak var large: UIButton!
    @IBOutlet weak var medium: UIButton!
    @IBOutlet weak var small: UIButton!
   
    @IBAction func largeButton(_ sender: Any) {
      let largeViewRegion = MKCoordinateRegion(center: mapView.centerCoordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01))
       mapView.setRegion(largeViewRegion, animated: true)
    }
    @IBAction func mediumButton(_ sender: Any) {
       let mediumViewRegion = MKCoordinateRegion(center: mapView.centerCoordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.0039, longitudeDelta: 0))
       mapView.setRegion(mediumViewRegion, animated: true)
    }
    @IBAction func smallButton(_ sender: Any) {
       let smallViewRegion = MKCoordinateRegion(center: mapView.centerCoordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.0017, longitudeDelta: 0))
       mapView.setRegion(smallViewRegion, animated: true)
    }
   
}

extension ViewController: MKMapViewDelegate {
   
    // Callout button press
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        let marker = view.annotation as! Tree
        let title = marker.title!
        let detail = marker.detail
      
      let alertController = CFAlertViewController(title: title, titleColor: UIColor(red: 0.0/255.0, green: 52.0/255.0, blue: 9.0/255.0, alpha: 1.0), message: "\(infoDictionary.dict[detail[3]]!) \n\n This Tree's Annual Impact \n CO2 Offset: \(detail[8]) lb / \(detail[9]) mi driven \n Total Carbon Stored: \(Int(Double(detail[10])!).commas) lb \n Air Pollution Removed: \(detail[11]) oz \n Rainfall Runoff Intercepted: \(detail[12]) gal", messageColor: UIColor.black, textAlignment: .center, preferredStyle: CFAlertViewController.CFAlertControllerStyle.alert, headerView: nil, footerView: nil, didDismissAlertHandler: nil)
        present(alertController, animated: true, completion: nil)
    }
   
   // Callout button bug workaround (Apple Radar 50352444)
   func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      view.superview!.bringSubviewToFront(view)
   }
   
   // Remove annotation based on map height
   func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
      if textFiltered == false {
         if (mapView.region.span.latitudeDelta > 0.0018) {
            mapView.removeAnnotations(smallAnnotations)
            small.backgroundColor = UIColor(red: 0.0/255.0, green: 52.0/255.0, blue: 9.0/255.0, alpha: 1.0)
            small.setTitleColor(UIColor.white, for: .normal)
         }
         if (mapView.region.span.latitudeDelta > 0.004) {
            mapView.removeAnnotations(mediumAnnotations)
            medium.backgroundColor = UIColor(red: 0.0/255.0, green: 52.0/255.0, blue: 9.0/255.0, alpha: 1.0)
            medium.setTitleColor(UIColor.white, for: .normal)
         }
         if (mapView.region.span.latitudeDelta <= 0.0018) {
            mapView.addAnnotations(smallAnnotations)
            small.backgroundColor = UIColor.white
            small.setTitleColor(UIColor(red: 0.0/255.0, green: 52.0/255.0, blue: 9.0/255.0, alpha: 1.0), for: .normal)
         }
         if (mapView.region.span.latitudeDelta <= 0.004) {
            mapView.addAnnotations(mediumAnnotations)
            medium.backgroundColor = UIColor.white
            medium.setTitleColor(UIColor(red: 0.0/255.0, green: 52.0/255.0, blue: 9.0/255.0, alpha: 1.0), for: .normal)
         }
      }
      else {
         small.backgroundColor = UIColor.white
         small.setTitleColor(UIColor(red: 0.0/255.0, green: 52.0/255.0, blue: 9.0/255.0, alpha: 1.0), for: .normal)
         medium.backgroundColor = UIColor.white
         medium.setTitleColor(UIColor(red: 0.0/255.0, green: 52.0/255.0, blue: 9.0/255.0, alpha: 1.0), for: .normal)
      }
   }

}

@IBDesignable extension UIButton {
   
   @IBInspectable var borderWidth: CGFloat {
      set {
         layer.borderWidth = newValue
      }
      get {
         return layer.borderWidth
      }
   }
   
   @IBInspectable var cornerRadius: CGFloat {
      set {
         layer.cornerRadius = newValue
      }
      get {
         return layer.cornerRadius
      }
   }
   
   @IBInspectable var borderColor: UIColor? {
      set {
         guard let uiColor = newValue else { return }
         layer.borderColor = uiColor.cgColor
      }
      get {
         guard let color = layer.borderColor else { return nil }
         return UIColor(cgColor: color)
      }
   }
}
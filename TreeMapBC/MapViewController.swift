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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var mapView: MKMapView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
      
        mapView.mapType = MKMapType.satellite
        mapView.delegate = self
      
        let initialLocation = CLLocation(latitude: 42.3361, longitude: -71.1677)
        let initialRegion = MKCoordinateRegion(center: initialLocation.coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(initialRegion, animated: true)
         
        mapView.register(TreeMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

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
   
   
    // Set up saved annotations for map height based removal
    var smallAnnotations = treeData.array.filter { Int($0.detail[6])! <= 10 }
    var mediumAnnotations = treeData.array.filter { Int($0.detail[6])! > 10 && Int($0.detail[6])! <= 30 }
    var textFiltered = false
   
   
   var defaultImpactData : [String] = []
   
   func setupDefaultImpactData() {
      
      var co2Offset = 0.0
      var distanceDriven = 0.0
      var carbonStorage = 0.0
      var pollutionRemoved = 0.0
      var waterIntercepted = 0.0
      
      for tree in treeData.array {
         co2Offset = co2Offset + Double(tree.detail[8])!
         distanceDriven = distanceDriven + Double(tree.detail[9])!
         carbonStorage = carbonStorage + Double(tree.detail[10])!
         pollutionRemoved = pollutionRemoved + Double(tree.detail[11])!
         waterIntercepted = waterIntercepted + Double(tree.detail[12])!
      }
      
      let treeCount = treeData.array.count
      defaultImpactData.append(String(treeCount.commas))
      defaultImpactData.append(String(Int(co2Offset).commas))
      defaultImpactData.append(String(Int(distanceDriven).commas))
      defaultImpactData.append(String(Int(Double(carbonStorage)).commas))
      defaultImpactData.append(String(Int(pollutionRemoved).commas))
      defaultImpactData.append(String(Int(waterIntercepted).commas))
      
   }
   
   
    var oldFilterData : [String:String] = [:]
   
    var filteredImpactData : [String] = []
   
    func sendData(filterData: [String:String]) {
      
        oldFilterData = filterData
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
      
      // Filtered environmental impact
      if !filterData.values.isEmpty {
         
         var co2Offset = 0.0
         var distanceDriven = 0.0
         var carbonStorage = 0.0
         var pollutionRemoved = 0.0
         var waterIntercepted = 0.0
         
         for tree in filteredTreeArray {
            co2Offset = co2Offset + Double(tree.detail[8])!
            distanceDriven = distanceDriven + Double(tree.detail[9])!
            carbonStorage = carbonStorage + Double(tree.detail[10])!
            pollutionRemoved = pollutionRemoved + Double(tree.detail[11])!
            waterIntercepted = waterIntercepted + Double(tree.detail[12])!
         }
         
         filteredImpactData = []
         let treeCount = filteredTreeArray.count
         filteredImpactData.append(String(treeCount.commas))
         filteredImpactData.append(String(Int(co2Offset).commas))
         filteredImpactData.append(String(Int(distanceDriven).commas))
         filteredImpactData.append(String(Int(Double(carbonStorage)).commas))
         filteredImpactData.append(String(Int(pollutionRemoved).commas))
         filteredImpactData.append(String(Int(waterIntercepted).commas))
      
      }
      
      else {
         
         filteredImpactData = []
         
      }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filterSegue" {
            let DestViewController = segue.destination as! UINavigationController
            let filterView = DestViewController.topViewController as! FilterViewController
            filterView.delegate = self
            filterView.oldFilterData = oldFilterData
        }
    }
   
   
   @IBAction func impactButton(_ sender: Any) {
      if filteredImpactData.isEmpty {
         if defaultImpactData.isEmpty {
            setupDefaultImpactData()
         }
         let alertController = CFAlertViewController(title: "Total Annual Impact", titleColor: UIColor(red: 0.0/255.0, green: 52.0/255.0, blue: 9.0/255.0, alpha: 1.0), message: "Number of Trees: \(defaultImpactData[0]) \n CO2 Offset: \(defaultImpactData[1]) lb / \(defaultImpactData[2]) mi driven \n Total Carbon Stored: \(defaultImpactData[3]) lb \n Air Pollution Removed: \(defaultImpactData[4]) oz \n Rainfall Runoff Intercepted: \(defaultImpactData[5]) gal", messageColor: UIColor.black, textAlignment: .center, preferredStyle: CFAlertViewController.CFAlertControllerStyle.alert, headerView: nil, footerView: nil, didDismissAlertHandler: nil)
         present(alertController, animated: true, completion: nil)
      }
      else {
         let alertController = CFAlertViewController(title: "Filtered Annual Impact", titleColor: UIColor(red: 0.0/255.0, green: 52.0/255.0, blue: 9.0/255.0, alpha: 1.0), message: "Number of Trees: \(filteredImpactData[0]) \n CO2 Offset: \(filteredImpactData[1]) lb / \(filteredImpactData[2]) mi driven \n Total Carbon Stored: \(filteredImpactData[3]) lb \n Air Pollution Removed: \(filteredImpactData[4]) oz \n Rainfall Runoff Intercepted: \(filteredImpactData[5]) gal", messageColor: UIColor.black, textAlignment: .center, preferredStyle: CFAlertViewController.CFAlertControllerStyle.alert, headerView: nil, footerView: nil, didDismissAlertHandler: nil)
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
      
      let alertController = CFAlertViewController(title: title, titleColor: UIColor(red: 0.0/255.0, green: 52.0/255.0, blue: 9.0/255.0, alpha: 1.0), message: "\(infoDictionary.dict[detail[3]] ?? "") \n\n This Tree's Annual Impact \n CO2 Offset: \(detail[8]) lb / \(detail[9]) mi driven \n Total Carbon Stored: \(Int(Double(detail[10])!).commas) lb \n Air Pollution Removed: \(detail[11]) oz \n Rainfall Runoff Intercepted: \(detail[12]) gal", messageColor: UIColor.black, textAlignment: .center, preferredStyle: CFAlertViewController.CFAlertControllerStyle.alert, headerView: nil, footerView: nil, didDismissAlertHandler: nil)
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

extension Int {
   
   private static var addCommas: NumberFormatter = {
      let numberFormatter = NumberFormatter()
      numberFormatter.numberStyle = .decimal
      return numberFormatter
   }()
   
   internal var commas: String {
      return Int.addCommas.string(from: NSNumber(value: self)) ?? ""
   }
   
}

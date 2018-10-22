import UIKit
import Mapbox
import MapKit

class MapViewController : UIViewController, MGLMapViewDelegate {
    
    var mapView : MGLMapView = MGLMapView()
    let streetMap = URL(string: "mapbox://styles/mapbox/outdoors-v9")
    let satelliteMap = URL(string: "mapbox://styles/mapbox/satellite-streets-v10")
    var nearbyAnnotations = [CustomPointAnnotation]()
    var historyAnnotations = [CustomPointAnnotation]()
    var mapCenter : CLLocationCoordinate2D?
    var nearbyStatus = false
    var locationsArray : [Location] = []
    
    @IBOutlet weak var mapViewHolder: UIView!
    @IBOutlet weak var showHistory: UISwitch!
    // @IBOutlet weak var showNearby: UISwitch!
    @IBOutlet weak var showTerrain: UISwitch!
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    class CustomPointAnnotation: MGLPointAnnotation {
        var isHistory: Bool = false
        var isNearby: Bool = false
        var isSearch: Bool = false
        
    }
    
    class CustomAnnotationView: MGLAnnotationView {
        override func layoutSubviews() {
            super.layoutSubviews()
            // Use CALayer’s corner radius to turn this view into a circle.
            layer.cornerRadius = bounds.width / 2
            layer.borderWidth = 2
            layer.borderColor = UIColor.white.cgColor
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            
            // Animate the border width in/out, creating an iris effect.
            let animation = CABasicAnimation(keyPath: "borderWidth")
            animation.duration = 0.1
            layer.borderWidth = selected ? bounds.width / 4 : 2
            layer.add(animation, forKey: "borderWidth")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup MapView
        mapView = MGLMapView(frame: mapViewHolder.bounds, styleURL: satelliteMap)
        mapView.allowsRotating = false
        mapView.allowsTilting = false
        mapView.showsScale = true
        if (mapView.isUserLocationVisible) {
            mapView.showsUserLocation = true
            mapView.showsUserHeadingIndicator = true
        }
        mapView.attributionButton.alpha = 0.1
        mapView.logoView.alpha = 0.1
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795), zoomLevel: 4, animated: false)
        
        mapViewHolder.addSubview(mapView)
        
        mapView.delegate = self
        
        let hello = CustomPointAnnotation()
        hello.coordinate = CLLocationCoordinate2D(latitude: 40.7326808, longitude: -73.9843407)
        hello.title = "Hello world!"
        hello.subtitle = "Welcome to my marker"
        hello.isHistory = true
        
        // Add marker `hello` to the map.
        mapView.addAnnotation(hello)
    }
    
//    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
//        return nil
//    }
    
    @IBAction func toggleHistory(_ sender: UISwitch) {
        // Get History Array and add it to the map
        if sender.isOn {
            let historyArray = readHistory()
            if !historyArray.isEmpty {
                // Append History
                for location in historyArray {
                    let point = CustomPointAnnotation()
                    point.isHistory = true
                    point.title = location.location
                    point.subtitle = location.company
                    point.coordinate = CLLocationCoordinate2D.init(latitude: location.latitude,
                                                                   longitude: location.longitude)
                    historyAnnotations.append(point)
                }
                mapView.addAnnotations(historyAnnotations)
            }
        } else {
            if !historyAnnotations.isEmpty {
                mapView.removeAnnotations(historyAnnotations)
            }
        }
        
    }
//    @IBAction func toggleNearby(_ sender: UISwitch) {
//        // Show nearby wells within 10Miles?
//        print(mapView.zoomLevel)
//        if sender.isOn {
//            nearbyStatus = true
//            locationsArray = readData(state: "nd")
//            getNearbyWells()
//        } else {
//            nearbyStatus = false
//            if !nearbyAnnotations.isEmpty {
//                mapView.removeAnnotations(nearbyAnnotations)
//            }
//        }
//    }
    @IBAction func toggleTerrain(_ sender: UISwitch) {
        // Toggle map from Satellite (true - default) to Streets (false)
        if sender.isOn {
            // Use satelliteMap
            mapView.styleURL = satelliteMap
        } else {
            // Use streetsMap
            mapView.styleURL = streetMap
        }
    }

//    func isNearby(near: CLLocation) -> Bool {
//        if let lat = mapCenter?.latitude, let lon = mapCenter?.longitude {
//            let target = CLLocation(latitude: lat, longitude: lon)
//            let distance = Int(target.distance(from: near))
//
//            if distance < 10000 {
//                return true
//            }
//        }
//        return false
//    }
//
//    func getNearbyWells() {
//        if !locationsArray.isEmpty {
//            // Append History
//            for location in locationsArray {
//                if (isNearby(near: CLLocation(latitude: location.latitude,
//                                              longitude: location.longitude))) {
//                    let point = CustomPointAnnotation()
//                    point.isNearby = true
//                    point.title = location.location
//                    point.subtitle = location.company
//                    point.coordinate = CLLocationCoordinate2D.init(latitude: location.latitude,
//                                                                   longitude: location.longitude)
//                    nearbyAnnotations.append(point)
//                }
//            }
//            mapView.addAnnotations(nearbyAnnotations)
//        }
//    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }

//    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
//        mapCenter = mapView.centerCoordinate
//        if nearbyStatus {
//            getNearbyWells()
//        }
//    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        let searchColor = UIColor(red:0.0, green:155/255.0, blue:218/255.0, alpha:1.0)
        let nearbyColor = UIColor(red:119/255.0, green:213/255.0, blue:115/255.0, alpha:1.0)
        let historyColor = UIColor(red:140/255.0, green:147/255.0, blue:153/255.0, alpha:0.7)
        
        if let custom = annotation as? CustomPointAnnotation {
            if (custom.isHistory) {
                // History well
                let reuseIdentifier = "historyDot"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
                
                if annotationView == nil {
                    annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
                    annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                    annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
                    annotationView?.layer.borderWidth = 4.0
                    annotationView?.layer.borderColor = UIColor.white.cgColor
                    annotationView!.backgroundColor = historyColor
                }
                
                return annotationView
            }
            if (custom.isNearby) {
                // Nearby well
                let reuseIdentifier = "nearbyDot"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
                
                if annotationView == nil {
                    annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
                    annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                    annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
                    annotationView?.layer.borderWidth = 4.0
                    annotationView?.layer.borderColor = UIColor.white.cgColor
                    annotationView!.backgroundColor = nearbyColor
                }
                
                return annotationView
            }
            if (custom.isSearch) {
                // Searched location
                let reuseIdentifier = "searchDot"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
                
                if annotationView == nil {
                    annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
                    annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                    annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
                    annotationView?.layer.borderWidth = 4.0
                    annotationView?.layer.borderColor = UIColor.white.cgColor
                    annotationView!.backgroundColor = searchColor
                }
                
                return annotationView
            }
        }
        
        let reuseIdentifier = "reusableDotView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
            annotationView?.layer.borderWidth = 4.0
            annotationView?.layer.borderColor = UIColor.white.cgColor
            annotationView!.backgroundColor = UIColor(red:0.03, green:0.80, blue:0.69, alpha:1.0)
        }
        
        return annotationView
    }
}

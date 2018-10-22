import UIKit
import MapKit
import MessageUI
import CoreLocation

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
    MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate {
    
    var usersLocation : CLLocation? = nil
    var selectedState : String? = nil
    var nearCity : String? = nil
    var historyArray : [Location] = []
    let locationManager = CLLocationManager()
    @IBOutlet weak var tableView: UITableView!
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "LocationViewCell", bundle: nil), forCellReuseIdentifier: "locationCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (allowLocation()) {
            getCurrentLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
        historyArray = readHistory()
        tableView.reloadData()
    }
    
    func getCurrentLocation() -> Void {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        locationManager.stopUpdatingLocation()
        usersLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
    }
    
    func allowLocation() -> Bool {
        // check if user allowed location services
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (currectReachability()) {
            getAddress(latitude: self.historyArray[indexPath.row].latitude, longitude: self.historyArray[indexPath.row].longitude) { result in
                // Set values when returned here
                let city = result.locality
                let state = result.administrativeArea
                self.nearCity = "\(city ?? ""), \(state ?? "")"
                self.taskAlert(message: "\(self.historyArray[indexPath.row].location) \nNear:\n\(self.nearCity ?? "unknown")", location: self.historyArray[indexPath.row])
            }
        } else {
            taskAlert(message: "\(self.historyArray[indexPath.row].location)", location: self.historyArray[indexPath.row])
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! LocationViewCell
        let blue = UIColor.init(red: 0.0/255, green: 155.0/255, blue: 218.0/255, alpha: 255)
        cell.backView.backgroundColor = blue
        cell.locationName.textColor = UIColor.white
        cell.nearestCity.textColor = UIColor.white
        cell.fieldName.textColor = UIColor.white
        let secondary = UIColor.init(red: 65.0/255, green: 75.0/255, blue: 82.0/255, alpha: 1)
        cell.companyName.textColor = secondary
        cell.locationCoordinates.textColor = secondary
        cell.LocationNameSmall.textColor = secondary
        
        addToHistory(location: historyArray[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! LocationViewCell
        let black = UIColor.init(red: 45.0/255, green: 50.0/255, blue: 55.0/255, alpha: 1)
        let secondary = UIColor.init(red: 140.0/255, green: 147.0/255, blue: 153.0/255, alpha: 1)
        cell.backView.backgroundColor = UIColor.white
        cell.locationName.textColor = black
        cell.nearestCity.textColor = black
        cell.fieldName.textColor = black
        cell.companyName.textColor = secondary
        cell.locationCoordinates.textColor = secondary
        cell.LocationNameSmall.textColor = secondary
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell") as! LocationViewCell
        let black = UIColor.init(red: 45.0/255, green: 50.0/255, blue: 55.0/255, alpha: 1)
        let secondary = UIColor.init(red: 140.0/255, green: 147.0/255, blue: 153.0/255, alpha: 1)
        cell.backView.backgroundColor = UIColor.white
        cell.locationName.textColor = black
        cell.nearestCity.textColor = black
        cell.fieldName.textColor = black
        cell.companyName.textColor = secondary
        cell.locationCoordinates.textColor = secondary
        cell.LocationNameSmall.textColor = secondary
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        
        UIView.animate(withDuration: 1.25, animations: { () -> Void in
            cell.alpha = 1
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! LocationViewCell
        
        cell.companyName.text  = self.historyArray[indexPath.row].company
        cell.fieldName.text  = self.historyArray[indexPath.row].field
        cell.LocationNameSmall.text = self.historyArray[indexPath.row].location
        cell.nearestCity.text = self.historyArray[indexPath.row].miles
        cell.locationCoordinates.text = "\(self.historyArray[indexPath.row].latitude), \(self.historyArray[indexPath.row].longitude)"
        cell.locationName.text = self.historyArray[indexPath.row].location
        
        if((usersLocation) != nil) {
            let location = CLLocation(latitude: self.historyArray[indexPath.row].latitude, longitude: self.historyArray[indexPath.row].longitude)
            
            let distanceInMeters = location.distance(from: usersLocation!)
            let milesAway = Int(Float(distanceInMeters/1609).rounded())
            let milesAwayText = milesAway >= 1 ? "\(milesAway) miles away" : "<1 mile away"
            cell.nearestCity.text = milesAwayText
        } else {
            cell.nearestCity.text = "Unknown"
        }
        
        return cell
    }
    
    func canSend() -> Bool {
        if !MFMessageComposeViewController.canSendText() {
            return false
        } else {
            return true
        }
    }
    
    // Share Well Site Via Text Message
    func sendTextMessage(message: String) -> Void {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        composeVC.body = message
        
        self.present(composeVC, animated: true, completion: nil)
    }
    // Dismiss Share Via Text Message
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func taskAlert(message: String, location: Location) {
        let task = UIAlertController(title: "Location", message: message, preferredStyle: .alert)
        
        task.addAction(UIAlertAction(title: "Get Directions", style: .default, handler: { _ in
            let coordinates = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapitem = MKMapItem(placemark: placemark)
            let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapitem.name = location.location
            mapitem.openInMaps(launchOptions: options)
            addToHistory(location: location)
        }))
        
        task.addAction(UIAlertAction(title: "Share via Text Message", style: .default, handler: { _ in
            let apple : String = "http://maps.apple.com/?q=\(location.latitude),\(location.longitude)"
            let android : String = "https://www.google.com/maps/search/?api=1&query=\(location.latitude),\(location.longitude)"
            let message : String = "Location:\n\(location.location)\n" +
                "(Near: \(self.nearCity ?? "unknown"))\n\n" +
                "Coordinates: (Lat,Lon)\n" +
                "\(location.latitude), \(location.longitude)\n\n" +
                "Apple iOS:\n\(apple)\n\nAndroid:\n\(android)\n\n" +
            "--Shared via NAVO"
            
            if (self.canSend()) {
                self.sendTextMessage(message: message)
                addToHistory(location: location)
            } else {
                let alert = UIAlertController(title: "Uh oh!", message: "It appears this deivce cannot send a message.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Copy Location Info", style: .default, handler: { _ in
                    UIPasteboard.general.string = message
                    addToHistory(location: location)
                }))
                alert.addAction(UIAlertAction(title: "Nevermind", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            
        }))
        task.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(task, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ViewController {
            let vc = segue.destination as? ViewController
            vc?.usersLocation = usersLocation
            vc?.selectedState = selectedState
        }
    }
}

import Swift
import MapKit
import D2PCurvedModal

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var usersLocation : CLLocation? = nil
    var selectedStateFull : String? = nil
    var selectedState : String? = nil
    var selectedCellIndexPath : IndexPath?
    let locationManager = CLLocationManager()
    let percentDrivenTransition = D2PCurvedModalPercentDrivenTransition()
    let transition = D2PCurvedModalTransition()
    
    @IBOutlet weak var searchingLabel: UILabel!
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction func searchBar(_ sender: UITextField) {
        if let count = sender.text?.count {
            if count > 2 {
                // Reload table with results
                filterWellSites(search: sender.text!)
            } else if count < 1 {
                filterWellSites(search: "")
                self.searchingLabel.text = "Start typing to begin new search"
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var locationsArray: [Location] = []
    var filterArray: [Location] = []
    var dataArray: [Location] = []
    
    override func viewDidAppear(_ animated: Bool) {
        if (allowLocation()) {
            getCurrentLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (selectedStateFull != nil && selectedStateFull != "") {
            searchingLabel.text = "Searching in \(selectedStateFull!)"
        } else {
            let readStateDefaults : (state: String, stateFull: String) = readDefaultState()
            selectedState = readStateDefaults.state
            selectedStateFull = readStateDefaults.stateFull
            searchingLabel.text = "Searching in \(selectedStateFull!)"
            
            if (selectedStateFull == "") {
                searchingLabel.text = "No state selected!"
                ALLoadingView.manager.hideLoadingView()
                let alert = UIAlertController(title: "Uh oh!", message: "No state selected. Select a state to begin your search.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let vc: UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
                    vc.selectedIndex = 0
                    self.present(vc, animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "AdViewCell", bundle: nil), forCellReuseIdentifier: "adCell")
        tableView.register(UINib(nibName: "LocationViewCell", bundle: nil), forCellReuseIdentifier: "locationCell")
        if(selectedState != nil) {
            if(hasData(state: selectedState!)) {
                // If local data found -> readData
                locationsArray = readData(state: selectedState!)
            } else {
                // No data found... Get from URL
                if (currectReachability()) {
                    // If service get well sites from URL
                    ALLoadingView.manager.blurredBackground = true
                    ALLoadingView.manager.messageFont = UIFont.systemFont(ofSize: 12.0)
                    ALLoadingView.manager.messageText = "Downloading Wells for \(selectedStateFull!)"
                    ALLoadingView.manager.itemSpacing = 20.0
                    ALLoadingView.manager.showLoadingView(ofType: .messageWithIndicator, windowMode: .windowed, completionBlock: {
                        downloadWellSites(state: self.selectedState!, cell: nil)
                        self.locationsArray = readData(state: self.selectedState!)
                    })
                }
            }
        }
    }
    
    func fillerArrayByWord(word: String, array: [Location]) -> [Location] {
        var returnableArray : [Location] = []
        for location in array {
            if location.location.lowercased().range(of:word.lowercased()) != nil {
                let newLocation = Location.init(company: location.company, location: location.location,
                                                latitude: location.latitude, longitude: location.longitude,
                                                field: location.field, county: location.county,
                                                api: location.api, miles: location.miles)
                returnableArray.append(newLocation)
            }
        }
        return returnableArray
    }
    
    func filterWellSites(search: String) -> Void {
        // Return Searched
        filterArray.removeAll()
        var finalArray : [Location] = []
        let searchArray : Array = search.split(separator: " ")
        var once = true
        for word in searchArray {
            if once {
                finalArray = fillerArrayByWord(word: String(word), array: locationsArray)
                once = false
            } else {
                finalArray = fillerArrayByWord(word: String(word), array: finalArray)
            }
        }
        
        if let state = selectedState {
            self.searchingLabel.text = "Searching in \(state.uppercased()) with \(finalArray.count) results out of \(locationsArray.count)."
        }
        dataArray = finalArray
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is HistoryViewController {
            let vc = segue.destination as? HistoryViewController
            vc?.usersLocation = usersLocation
            vc?.selectedState = selectedState
        }
    }
}


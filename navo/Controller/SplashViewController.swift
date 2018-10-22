import UIKit
import MapKit

class SplashViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource  {
    
    // MARK: Variables --------------------------------------------------------------------------
    var usersLocation : CLLocation? = nil
    var selectedState : String? = nil
    var setLocation : Bool = false
    let locationManager = CLLocationManager()
    let stateList : [[String:Any]] = [
        ["state":"Alabama", "abbreviation":"al", "tag": 100],
        ["state":"Alaska", "abbreviation":"ak", "tag": 101],
        ["state":"Arkansas", "abbreviation":"ar", "tag": 102],
        ["state":"California", "abbreviation":"ca", "tag": 103],
        ["state":"Colorado", "abbreviation":"co", "tag": 104],
        ["state":"Florida", "abbreviation":"fl", "tag": 105],
        ["state":"Kansas", "abbreviation":"ks", "tag": 106],
        ["state":"Kentucky", "abbreviation":"ky", "tag": 107],
        ["state":"Louisiana", "abbreviation":"la", "tag": 108],
        ["state":"Michigan", "abbreviation":"mi", "tag": 109],
        ["state":"Mississippi", "abbreviation":"ms", "tag": 110],
        ["state":"Missouri", "abbreviation":"mo", "tag": 111],
        ["state":"Montana", "abbreviation":"mt", "tag": 112],
        ["state":"North Dakota", "abbreviation":"nd", "tag": 113],
        ["state":"Nebraska", "abbreviation":"ne", "tag": 114],
        ["state":"New Mexico", "abbreviation":"nm", "tag": 115],
        ["state":"New York", "abbreviation":"ny", "tag": 116],
        ["state":"Ohio", "abbreviation":"oh", "tag": 117],
        ["state":"Oklahoma", "abbreviation":"ok", "tag": 118],
        ["state":"Pennsylvania", "abbreviation":"pa", "tag": 119],
        ["state":"South Dakota", "abbreviation":"sd", "tag": 120],
        ["state":"Texas", "abbreviation":"tx", "tag": 121],
        ["state":"Utah", "abbreviation":"ut", "tag": 122],
        ["state":"West Virginia", "abbreviation":"wv", "tag": 123],
        ["state":"Wyoming", "abbreviation":"wy", "tag": 124]]
    
    // MARK: Outlets ----------------------------------------------------------------------------
    @IBOutlet var tableView: UITableView!
    
    // MARK: ViewDidLoad ------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // TableView Setup
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "StateViewCell",
                                 bundle: nil), forCellReuseIdentifier: "stateViewCell")
        tableView.register(UINib(nibName: "LocationSettingsViewCell",
                                 bundle: nil), forCellReuseIdentifier: "locationSettingsCell")
        tableView.register(UINib(nibName: "DownloadedViewCell",
                                 bundle: nil), forCellReuseIdentifier: "downloadStateCell")
    }
    
    // MARK: ViewDidAppear ----------------------------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        checkLocation()
//        if (allowLocation()) {
//            getCurrentLocation()
//            setLocation = true
//        } else {
//            setLocation = false
//            self.locationManager.requestWhenInUseAuthorization()
//        }
    }
    
    // MARK: Location Manager -------------------------------------------------------------------
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
    
    // MARK: TableView --------------------------------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return stateList.count
        } else if section == 2 {
            return 1 // User Location Setting - Static
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Select a state to beigin search"
        } else if section == 1 {
            return "Downloaded State Data (Click to Update)"
        } else if section == 2 {
            return "Location Setting"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Selecting a state will set a default next time you run the application. First time selecting a state will take longer as it is downloading the well site data."
        } else if section == 1 {
            return "Updates avaiable every month. Check mark will change to a Refresh symbol to signal an update is avaiable."
        } else if section == 2 {
            return "Your location only while using application to display distantance away from the well site."
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.00
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "stateViewCell", for: indexPath) as! StateViewCell

            cell.stateName.text = (stateList[indexPath.row]["state"]! as! String)
            cell.stateFlag.image = UIImage(named:stateList[indexPath.row]["abbreviation"]! as! String)
            cell.tag = stateList[indexPath.row]["tag"]! as! Int
            cell.selectionStyle = .none
            
            return cell
        }
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "downloadStateCell", for: indexPath) as! DownloadedViewCell
            
            cell.stateName.text = (stateList[indexPath.row]["state"]! as! String)
            cell.stateFlag.image = UIImage(named:stateList[indexPath.row]["abbreviation"]! as! String)
            cell.stateStatus.image = downloaderImage(state: stateList[indexPath.row]["abbreviation"] as! String)
            cell.tag = stateList[indexPath.row]["tag"]! as! Int
            cell.selectionStyle = .none
            
            return cell
        }
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationSettingsCell", for: indexPath) as! LocationSettingsViewCell
            cell.selectionStyle = .none
            cell.tag = 999
            cell.locationSwitch.isOn = checkLocation()
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            switch cell.tag {
            case 99...200:
                if (indexPath.section == 0) {
                    saveDefaultState(state: stateList[cell.tag-100]["abbreviation"] as! String,
                                     stateFull: stateList[cell.tag-100]["state"] as! String)
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let vc: UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
                    vc.selectedIndex = 2
                    self.present(vc, animated: true, completion: nil)
                } else if (indexPath.section == 1) {
                    ALLoadingView.manager.blurredBackground = true
                    ALLoadingView.manager.messageFont = UIFont.systemFont(ofSize: 12.0)
                    ALLoadingView.manager.messageText = "Downloading Wells for \(stateList[cell.tag-100]["state"]!)"
                    ALLoadingView.manager.itemSpacing = 32.0
                    ALLoadingView.manager.showLoadingView(ofType: .messageWithIndicator, windowMode: .windowed, completionBlock: {
                        downloadWellSites(state: self.stateList[indexPath.row]["abbreviation"]! as! String, cell: cell as? DownloadedViewCell)
                    })
                }
                break
            case 999:
                // Allow Location
                let alert = UIAlertController(title: "Location Services",
                                              message: "Allows app to display distance away from oil wells." +
                                                "\nTo change this go to:\nSettings->Privacy->\nLocation Services." +
                                                "\nThen find the application: Navo", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                break
            default:
                // Do nothing...
                break
            }
        }
    }
    
    // MARK: Various ----------------------------------------------------------------------------
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func checkLocation() -> Bool {
        if (allowLocation()) {
            getCurrentLocation()
            return true
        } else {
            
            self.locationManager.requestWhenInUseAuthorization()
            return false
        }
    }
    
    func downloaderImage(state: String) -> UIImage {
        if (hasData(state: state)){
            return UIImage(named: "check")!
        }
        return UIImage(named: "download")!
    }
}

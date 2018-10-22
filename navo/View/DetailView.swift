import UIKit
import GoogleMobileAds
import MapKit
import MessageUI

class DetailView: UIViewController, MFMessageComposeViewControllerDelegate, UITabBarDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var bannerView2: GADBannerView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var apiLabel: UILabel!
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var fieldLabel: UILabel!
    
    @IBOutlet weak var oneCallView: UIView!
    @IBOutlet weak var oneCallCover: UIView!
    
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var quarterLabel: UILabel!
    @IBOutlet weak var townshipLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    
    @IBOutlet weak var nearCityLabel: UILabel!
    @IBOutlet weak var streetsTitle: UILabel!
    @IBOutlet weak var streetsLabel: UILabel!
    @IBOutlet weak var drivingDirections: UITextView!
    
    @IBOutlet weak var actionTabs: UITabBar!
    
    @IBAction func unlockOneCall(_ sender: UIButton) {
        // Go to Subscriptions
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc: UITabBarController = mainStoryboard
            .instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
        vc.selectedIndex = 4
        self.present(vc, animated: false, completion: {
            if let statusbar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                statusbar.backgroundColor = UIColor
                    .init(red: 0.0/255, green: 158.0/255, blue: 222.0/255, alpha: 1.0)
            }
        })
    }
    
    var usersLocation : CLLocation?
    var nearCity : String? = nil
    var nearState : String? = nil
    var nearCityLocation : CLLocation?
    var location : Location? = nil
    let username = "keisto"
    let password = "navoPassword"
    let googleKey = "AIzaSyBQNJ_IErXN3XUkznUM56s7C_Q8LDbDsG4"
    var intersection : [String:String] = [:]
    var streets : [String] = []
    
    // Check each time viewDidAppear
    let adSubscription = false
    let oneCallSubscription = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionTabs.delegate = self
        
        oneCallView.layer.cornerRadius = 6
        oneCallCover.layer.cornerRadius = 6
        bannerView.layer.cornerRadius = 6
        bannerView2.layer.cornerRadius = 6
        
        if let location = location {
            locationLabel.text = location.location
            apiLabel.text = location.api
            coordinatesLabel.text = "\(location.latitude), \(location.longitude)"
            if location.field != "" {
                fieldLabel.text = location.field
            } else {
                fieldLabel.text = "Field not found."
            }
            
            if (currectReachability()) {
                // One Caller ---------------------------------------------------------------
                if oneCallSubscription {
                    ALLoadingView.manager.blurredBackground = true
                    ALLoadingView.manager.messageFont = UIFont.systemFont(ofSize: 12.0)
                    ALLoadingView.manager.messageText = "Gathering Infromation \n Please Wait..."
                    ALLoadingView.manager.itemSpacing = 32.0
                    ALLoadingView.manager.showLoadingView(ofType: .messageWithIndicator, windowMode: .windowed, completionBlock: {
                        self.getOneCallInfo(user: self.username, pass: self.password,
                                            lat: "\(location.latitude)", lon: "\(location.longitude)")
                        getAddress(latitude: location.latitude, longitude: location.longitude) { result in
                            // Set values when returned here
                            let city = result.locality
                            let state = result.administrativeArea
                            self.nearCity = "\(city ?? "City not found")"
                            self.nearState = "\(state ?? "")"
                            self.nearCityLabel.text = "\(self.nearCity!) (\(location.county))"
                            
                            if let city = city, let state = state {
                                getCoordinates(city: city, state: state) { result in
                                    self.nearCityLocation = result.location
                                    if let nearCityLocation = self.nearCityLocation {
                                        self.getDrivingDirections(nearLocation: nearCityLocation,
                                                                  lat: "\(location.latitude)",
                                            lon: "\(location.longitude)")
                                    }
                                }
                            }
                            ALLoadingView.manager.hideLoadingView()
                        }
                    })
                }
            } // End One Caller -----------------------------------------------------------
        }
        
//                if (currectReachability()) {
//                    getAddress(latitude: location.latitude, longitude: self.dataArray[indexPath.row].longitude) { result in
//                        // Set values when returned here
//                        let city = result.locality
//                        let state = result.administrativeArea
//                        self.nearCity = "\(city ?? ""), \(state ?? "")"
//                        self.taskAlert(message: "\(self.dataArray[indexPath.row].location) \nNear:\n\(self.nearCity ?? "unknown")", location: self.dataArray[indexPath.row])
//                    }
//                } else {
//                    taskAlert(message: "\(self.dataArray[indexPath.row].location)", location: self.dataArray[indexPath.row])
//                }
    }
    override func viewDidAppear(_ animated: Bool) {
        
        // if ad removal subscription
        
        
        if adSubscription {
            bannerView.frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
            bannerView2.frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
            self.view.layoutIfNeeded()
        } else {
            bannerView.adUnitID = "ca-app-pub-8967968920199965/8527163490"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            
            bannerView2.adUnitID = "ca-app-pub-8967968920199965/8527163490"
            bannerView2.rootViewController = self
            bannerView2.load(GADRequest())
        }
        
        if oneCallSubscription {
            oneCallCover.isHidden = true
        } else {
            oneCallCover.isHidden = false
            
        }
    
        // if onecall subscription...
//        oneCallView.isHidden = true
    }
    
    // MARK: Action Items
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let location = location {
            
            switch item.tag {
            case 0:
                // 0 == Begin Naviagtion
                let coordinates = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                let mapitem = MKMapItem(placemark: placemark)
                let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                mapitem.name = location.location
                mapitem.openInMaps(launchOptions: options)
                break
            case 1:
                // 1 == Show on Map
                
                break
            case 2:
                // 2 == Share
                var string : String
                if oneCallSubscription {
                    string = "Well Name: \n\(location.location) \n\n Nearest City: \n\(self.nearCity ?? "Not Found")"
                } else {
                    string = "Well Name: \n\(location.location)"
                }
                taskAlert(message: string, location: location)
                break
            default:
                break
            }
            
            addToHistory(location: location)
        }
        tabBar.selectedItem = nil
    }

    
    func getOneCallInfo(user : String, pass: String, lat: String, lon: String) -> Void {
        let url = URL(string: "http://legallandconverter.com/cgi-bin/android5c.cgi?" +
        "username=\(user)&password=\(pass)&latitude=\(lat)&longitude=\(lon)&cmd=gps")
        do {
            let string = try String(contentsOf: url!, encoding: .ascii)

            var array : [String : String] = [:]
            for i in string.components(separatedBy: .newlines) {
                if i.contains(":") {
                    let key = i.split(separator: ":")[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let value = i.split(separator: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines)

                    array[key] = value
                }
            }

            let locationDetails = OneCall.init(section: "\(array["USASECTION"] ?? "--")",
                                               range: "\(array["USARANGE"] ?? "-")\(array["USAEASTWEST"] ?? "-")",
                                               township: "\(array["USATOWNSHIP"] ?? "-")\(array["USANORTHSOUTH"] ?? "-")",
                                               quarter: "\(array["USAQUARTER"] ?? "--")")

            sectionLabel.text = locationDetails.section
            quarterLabel.text = locationDetails.quarter
            townshipLabel.text = locationDetails.township
            rangeLabel.text = locationDetails.range
        
            getIntersection(user: user, lat: lat, lon: lon)
        
            if locationDetails.township == "--" {
                // TODO: Alert -> Apologize to the user
            }

        } catch {
            // Oops!
        }
    }
    
    // MARK: Messaging & Alerts -----------------------------------------------------------------
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
        
//        task.addAction(UIAlertAction(title: "Get Directions", style: .default, handler: { _ in
//            let coordinates = CLLocationCoordinate2DMake(location.latitude, location.longitude)
//            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
//            let mapitem = MKMapItem(placemark: placemark)
//            let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
//            mapitem.name = location.location
//            mapitem.openInMaps(launchOptions: options)
//        }))

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
            } else {
                let alert = UIAlertController(title: "Uh oh!", message: "It appears this deivce cannot send a message.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Copy Location Info", style: .default, handler: { _ in
                    let pasteBoard = UIPasteboard.general
                    pasteBoard.string = "\(message)"
                }))
                alert.addAction(UIAlertAction(title: "Nevermind", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }))
        task.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(task, animated: true, completion: nil)
    }
}

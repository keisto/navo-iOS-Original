import Swift
import MapKit

func hasData(state: String) -> Bool {
    if (UserDefaults.standard.object(forKey: state)as? NSData) != nil {
        return true
    }
    return false
}

func readDataCount(state: String) -> Int {
    // Get data count if lessthan than newDataCount -> new wells avaiable
    if let data = UserDefaults.standard.object(forKey: state)as? NSData {
        let array = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [Location]
        return array.count
    }
    return 0
}

func newDataCount(state: String) -> Int {
    let url = URL(string:"http://162.243.142.227/wells/\(state).json")
    do {
        let allLocationsData = try Data(contentsOf: url!)
        let allLocations = try JSONSerialization
            .jsonObject(with: allLocationsData, options: JSONSerialization
                .ReadingOptions.allowFragments) as! Array<AnyObject>
        return allLocations.count
    } catch {
        // Oops!
    }
    return 0
}

func saveDefaultState(state: String, stateFull: String) -> Void {
    UserDefaults.standard.set(state, forKey: "stateDefault")
    UserDefaults.standard.set(stateFull, forKey: "stateFullDefault")
}

func readDefaultState() -> (state: String, stateFull: String) {
    if let stateDefault = UserDefaults.standard.string(forKey: "stateDefault"),
       let stateFullDefault = UserDefaults.standard.string(forKey: "stateFullDefault") {
        return (stateDefault, stateFullDefault)
    }
    return ("", "")
}

func readData(state: String) -> [Location] {
    if let data = UserDefaults.standard.object(forKey: state)as? NSData {
        let array = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [Location]
        return array
    }
    return []
}

func writeData(state: String, array: [Location]) -> Void {
    // Save Data on Device
    print("about to write")
    let data = NSKeyedArchiver.archivedData(withRootObject: array)
    UserDefaults.standard.set(data, forKey: state)
    print("written")
}

func addToHistory(location: Location) -> Void {
    // Add recently located well site locations to history to recent history
    var historyArray : [Location] = readHistory().reversed()
    for item in historyArray {
        if (item.location == location.location &&
            item.latitude == location.latitude &&
            item.longitude == location.longitude) {
            historyArray.remove(at: historyArray.index(of: item)!)
        }
    }
    // Append new location
    historyArray.append(location)
    let data = NSKeyedArchiver.archivedData(withRootObject: historyArray)
    UserDefaults.standard.set(data, forKey: "history")
    print("location added \(location)")
}

func readHistory() -> [Location] {
    var historyArray : [Location] = []
    if let data = UserDefaults.standard.object(forKey: "history")as? NSData {
        historyArray = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [Location]
        return historyArray.reversed()
    }
    return historyArray.reversed()
}

func getAddress(latitude: Double, longitude: Double,
                completion: @escaping (CLPlacemark) -> ()) {
    let currentLocation = CLLocation(latitude: latitude, longitude: longitude)
    let geoCoder = CLGeocoder()
    geoCoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) -> Void in
        
        if error == nil {
            let placeArray = placemarks as [CLPlacemark]?
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            completion(placeMark)
        }
    }
}

func getCoordinates(city: String, state: String,
                completion: @escaping (CLPlacemark) -> ()) {
    let geoCoder = CLGeocoder()
    geoCoder.geocodeAddressString("\(city), \(state)") { (placemarks, error) -> Void in
        
        if error == nil {
            let placeArray = placemarks as [CLPlacemark]?
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            completion(placeMark)
        }
    }
}


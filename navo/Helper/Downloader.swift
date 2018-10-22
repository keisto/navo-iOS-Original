import UIKit

var locationsArray: [Location] = []

func downloadWellSites(state: String, cell: DownloadedViewCell?) {
    if (state == "tx") {
        localLoadTx(state: state, cell: cell)
    } else if (state == "ks") {
        localLoadKs(state: state, cell: cell)
    } else {
        locationsArray = []
        let url = URL(string:"http://162.243.142.227/wells/\(state).json")
        do {
            print("downloading - start")
            let allLocationsData = try Data(contentsOf: url!)
            let allLocations = try JSONSerialization
                .jsonObject(with: allLocationsData, options: JSONSerialization
                    .ReadingOptions.allowFragments) as! Array<AnyObject>
            print("downloading - data found")
            for i in allLocations {
                if (i["lat"] as? Double ?? 0.0 != 0.0) {
                    // If no latitude, we can't use it
                    if (i["full_display_api_no"] as? String ?? "" != "") {
                        processLocationMain(object: i, state: state)
                    } else if (i["api"] as? String ?? "" != "" || i["api"] as? Int ?? 0 > 0) {
                        processLocationSecondary(object: i, state: state)
                    }
                }
            }
            writeData(state: state, array: locationsArray)
            cell?.stateStatus.image = UIImage(named: "check")
            ALLoadingView.manager.hideLoadingView()
        } catch {
            // Oops!
        }
    }
}

func safeReturnLocation(location : String) -> String {
    let a = location.replacingOccurrences(of: "  ", with: " ")
    let b = a.replacingOccurrences(of: "- ", with: "-")
    let c = b.replacingOccurrences(of: "   ", with: " ")
    let d = c.replacingOccurrences(of: "    ", with: " ")
    let e = d.replacingOccurrences(of: "  ", with: " ")
    let locationName = e.replacingOccurrences(of: " -", with: "-")
    return locationName
}

func safeReturnAPI(api: String) -> String {
    return api.replacingOccurrences(of: "-", with: "")
}

func safeReturnCounty(county: String) -> String {
    if (county == "") {
        return "County Not Set"
    }
    return county.replacingOccurrences(of: " County", with: "")
}

func processLocationMain(object: AnyObject, state: String) {
    let location = object["well_name"] as? String ?? "Not Set"
    let latitude = object["lat"] as? Double ?? 0.00
    let longitude = object["lon"] as? Double ?? 0.00
    let company = object["operator_name"] as? String ?? "Unknown"
    let field = object["field_name"] as? String ?? "Unknown"
    let county = safeReturnCounty(county: object["county_full"] as? String ?? "Unknown")
    let api = safeReturnAPI(api: object["full_display_api_no"] as? String ?? "Uknown")
    
    let newLocation = Location.init(company: company, location: location,
                                    latitude: latitude, longitude: longitude,
                                    field: field, county: county, api: api, miles: "")
    locationsArray.append(newLocation)
}

func processLocationSecondary(object: AnyObject, state: String) {
    let location = safeReturnLocation(location: object["well"] as? String ?? "Not Set")
    let latitude = object["lat"] as? Double ?? 0.00
    let longitude = object["lon"] as? Double ?? 0.00
    let company = object["company"] as? String ?? "Unknown"
    let field = object["field"] as? String ?? "Unknown"
    let county = object["county"] as? String ?? "Unknown"
    let api = "\(object["api"] as? Int ?? 0)"
    
    let newLocation = Location.init(company: company, location: location,
                                    latitude: latitude, longitude: longitude,
                                    field: field, county: county, api: api, miles: "")
    locationsArray.append(newLocation)
}

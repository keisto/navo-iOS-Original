import UIKit

func localLoadTx (state: String, cell: DownloadedViewCell?) {
    locationsArray = []
    var count = 1
    while count != 12 {
        if let path = Bundle.main.path(forResource: "\(state)\(count)", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let allLocations = try JSONSerialization
                    .jsonObject(with: data, options: JSONSerialization
                        .ReadingOptions.allowFragments) as! Array<AnyObject>
                for i in allLocations {
                    if (i["t"] as? Double ?? 0.0 != 0.0) {
                        // Large files need to paginate and api request -- Solve in Version 3
                        let location = processLocationLocal(object: i, state: state)!
                        locationsArray.append(location)
                    }
                }
                print("Loaded: \(count)\n")
                if (count == 11) {
                    writeData(state: state, array: locationsArray)
                    print(locationsArray.count)
                    cell?.stateStatus.image = UIImage(named: "check")
                    ALLoadingView.manager.hideLoadingView()
                }
            } catch {
                //  Oops!
            }
        }
        count+=1
    }
}


func localLoadKs (state: String, cell: DownloadedViewCell?) {
    locationsArray = []
    if let path = Bundle.main.path(forResource: "\(state)1", ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let allLocations = try JSONSerialization
                .jsonObject(with: data, options: JSONSerialization
                    .ReadingOptions.allowFragments) as! Array<AnyObject>
            for i in allLocations {
                if (i["lat"] as? Double ?? 0.0 != 0.0) {
                    // Large files need to paginate and api request -- Solve in Version 3
                    if let location = processLocationLocal(object: i, state: state) {
                        locationsArray.append(location)
                    }
                }
            }
        } catch {
            //  Oops!
        }
    }
    if let path = Bundle.main.path(forResource: "\(state)2", ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let allLocations = try JSONSerialization
                .jsonObject(with: data, options: JSONSerialization
                    .ReadingOptions.allowFragments) as! Array<AnyObject>
            for i in allLocations {
                if (i["lat"] as? Double ?? 0.0 != 0.0) {
                    // Large files need to paginate and api request -- Solve in Version 3
                    if let location = processLocationLocal(object: i, state: state) {
                        locationsArray.append(location)
                    }
                }
            }
            writeData(state: state, array: locationsArray)
            print(locationsArray.count)
            cell?.stateStatus.image = UIImage(named: "check")
            ALLoadingView.manager.hideLoadingView()
        } catch {
            //  Oops!
        }
    }
}





func processLocationLocal(object: AnyObject, state: String) -> Location? {
    if state == "ks" {
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
        return newLocation
    } else if state == "tx" {
        let location = object["w"] as? String ?? "Not Set"
        let latitude = object["t"] as? Double ?? 0.00
        let longitude = object["g"] as? Double ?? 0.00
        let company = object["c"] as? String ?? "Unknown"
        let field = object["f"] as? String ?? "Unknown"
        let county = safeReturnCounty(county: object["c"] as? String ?? "Unknown")
        let api = safeReturnAPI(api: object["a"] as? String ?? "Uknown")
        
        let newLocation = Location.init(company: company, location: location,
                                        latitude: latitude, longitude: longitude,
                                        field: field, county: county, api: api, miles: "")
        return newLocation
    }
    return nil
}

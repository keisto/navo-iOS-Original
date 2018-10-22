import Foundation
import Alamofire
import MapKit

/*
 Function calls to get location info:
 - Driving Directions
 - Nearest Intersetions
 - Nearby Streets
*/

extension DetailView {
    func getIntersection(user : String, lat: String, lon: String) -> Void {
        let nearestIntersection = "http://api.geonames.org/findNearestIntersectionJSON?" +
        "formatted=true&lat=\(33.5020523071289)&lng=\(-112.329467773438)&username=keisto&style=full"
        Alamofire.request(nearestIntersection).responseJSON { response in
            if let json = response.result.value as? [String: Any] {
                if let intersection = json["intersection"] as? [String:String] {
                    // Process Intersection...
                    if let street1 = intersection["street1"],
                        let street2 = intersection["street2"] {
                        if street1 != "" {
                            self.intersection["a"] = street1
                        } else {
                            self.intersection["a"] = "Unnamed Lease Rd"
                        }
                        
                        if street2 != "" {
                            self.intersection["b"] = street2
                        } else {
                            self.intersection["b"] = "Unnamed Lease Rd"
                        }
                    }
                    if self.intersection.isEmpty {
                        self.getNearbyStreets(user: user, lat: lat, lon: lon)
                    } else {
                        self.streetsTitle.text = "Nearest Intersection"
                        self.streetsLabel.text = "A: \(self.intersection["a"]!)\n" +
                        "B: \(self.intersection["b"]!)"
                    }
                    return
                }
            }
            
            self.getNearbyStreets(user: user, lat: lat, lon: lon)
            return
        }
    }

    func getNearbyStreets(user : String, lat: String, lon: String) -> Void {
        let nearestIntersection = "http://api.geonames.org/findNearbyStreetsJSON?" +
        "formatted=true&lat=\(lat)&lng=\(lon)&username=\(user)&style=full"
        Alamofire.request(nearestIntersection).responseJSON { response in

            if let json = response.result.value as? [String: Any] {
                if let streets = json["streetSegment"] as? [[String:String]] {
                    // Process Nearby Streets
                    for street in streets {
                        if self.streets.isEmpty {
                            self.streets.append(street["name"] ?? "Unnamed Lease Rd")
                        } else if !self.streets.contains(street["name"] ?? "Unnamed Lease Rd") {
                            if (street["name"] == "") {
                                if !self.streets.contains("Unnamed Lease Rd") {
                                    self.streets.append("Unnamed Lease Rd")
                                }
                            } else {
                                self.streets.append(street["name"] ?? "Unnamed Lease Rd")
                            }
                        }
                    }
                    self.streetsTitle.text = "Nearby streets (no intersection found)"
                    self.streetsLabel.text = "\(self.streets.joined(separator: "\n"))"
                    return
                }
            }
            
            if self.streets.isEmpty {
                self.streetsTitle.text = "Unable to find street info"
                self.streetsLabel.text = "Sorry for the inconvenience."
            }
            return
        }
    }

    func getDrivingDirections(nearLocation: CLLocation, lat: String, lon: String) {
        let drivingDirections = "https://maps.googleapis.com/maps/api/directions/json?origin=" +
            "\(nearLocation.coordinate.latitude),\(nearLocation.coordinate.longitude)" +
            "&destination=\(lat),\(lon)&key=\(googleKey)"
        print(drivingDirections)
        Alamofire.request(drivingDirections).responseJSON { response in
            if let json = response.result.value as? [String:Any] {
                if let routes = json["routes"] as? [[String:Any]] {
                    if let legs = routes[0]["legs"] as? [[String:Any]] {
                      /*
                            if let distance = legs[0]["distance"] as? [String: Any] {
                                // Total Distance
                                print(distance["text"] as! String)
                            }
                            if let duration = legs[0]["duration"] as? [String: Any] {
                                // Total Duration
                                print(duration["text"] as! String)
                            }
                            */
                        var stepsArray : [String] = []
                        if let steps = legs[0]["steps"] as? [[String: Any]] {
                            
                            for step in steps {
                                if let distance = step["distance"] as? [String: Any],
                                    let instructions = step["html_instructions"] as? String {
                                    // let duration = step["duration"] as? [String: Any]
                                    // stepsArray.append("\(instructions) - \(distance["text"]!) (\(duration["text"]!))")
                                    stepsArray.append("\(instructions) - \(distance["text"]!)")
                                }
                            }
                            let htmlData = NSString(string: "From \(self.nearCity ?? ""), \(self.nearState ?? ""): \(stepsArray.joined(separator: ", "))")
                                            .data(using: String.Encoding.unicode.rawValue)
                            let attributedString = try!
                                NSAttributedString(data: htmlData!,
                                                   options: [NSAttributedString.DocumentReadingOptionKey
                                                    .documentType: NSAttributedString.DocumentType.html],
                                                   documentAttributes: nil)
                            self.drivingDirections.attributedText = attributedString
                        }
                    }
                   
                    return
                }
            }
            // else couldnt get driving directions
            self.drivingDirections.text = "Failed to get driving directions."
            return
        }
    }
}

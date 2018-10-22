import Foundation

class Location : NSObject, NSCoding {
    var company   : String = "Unknown"
    var field     : String = "Unknown"
    var api       : String = "Unknown"
    var county    : String = "Unknown"
    var miles     : String = "Unknown"
    var location  : String = "Unknown"
    var latitude  : Double
    var longitude : Double

    init(company : String, location : String, latitude : Double, longitude : Double,
         field : String = "Not Found", county: String, api: String = "Not Found", miles : String) {
        self.company   = company
        self.location  = location
        self.latitude  = latitude
        self.longitude = longitude
        self.field     = field
        self.miles     = miles
        self.county    = county
        self.api       = api
    }
    
    required init(coder decoder: NSCoder) {
        self.company   = decoder.decodeObject(forKey: "company") as! String
        self.field     = decoder.decodeObject(forKey: "field") as! String
        self.miles     = decoder.decodeObject(forKey: "miles") as! String
        self.location  = decoder.decodeObject(forKey: "location") as! String
        self.latitude  = decoder.decodeDouble(forKey: "latitude")
        self.longitude = decoder.decodeDouble(forKey: "longitude")
        self.county    = decoder.decodeObject(forKey: "county") as? String ?? "Unkown"
        self.api       = decoder.decodeObject(forKey: "api") as? String ?? "Unkown"
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(company,   forKey: "company")
        coder.encode(field,     forKey: "field")
        coder.encode(miles,     forKey: "miles")
        coder.encode(location,  forKey: "location")
        coder.encode(latitude,  forKey: "latitude")
        coder.encode(longitude, forKey: "longitude")
        coder.encode(county,    forKey: "county")
        coder.encode(api,       forKey: "api")
    }
}

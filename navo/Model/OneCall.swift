import Foundation

class OneCall: NSObject {
    var section  : String
    var range    : String
    var township : String
    var quarter  : String
    
    init(section : String, range : String, township : String, quarter : String) {
        self.section  = section
        self.range    = range
        self.township = township
        self.quarter  = quarter
    }
}


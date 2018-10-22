import UIKit
import MapKit
import D2PCurvedModal
import GoogleMobileAds

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    
    // MARK: TableView Setup --------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailView(nibName: "DetailView", bundle: Bundle(for: DetailView.self))
        let modalVC = D2PCurvedModal(nibName: "D2PCurvedModal", bundle: Bundle(for: D2PCurvedModal.self))
        let selectedLocation = self.dataArray[indexPath.row]
        detailVC.location = selectedLocation
        detailVC.usersLocation = self.usersLocation
    
        modalVC.setUpViewOf(viewController: detailVC)
        modalVC.closeBtnBgColor = UIColor.init(red: 0.0/255, green: 158.0/255, blue: 222.0/255, alpha: 1.0)
        modalVC.containerHeight = self.view.frame.height - 144
        modalVC.transitioningDelegate = self
        percentDrivenTransition.attachToViewController(viewController: modalVC)
    
        present(modalVC, animated: true, completion: nil)
        
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
        
        if selectedCellIndexPath != nil && selectedCellIndexPath == indexPath {
            selectedCellIndexPath = nil
        } else {
            selectedCellIndexPath = indexPath
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
        if selectedCellIndexPath != nil {
            // This ensures, that the cell is fully visible once expanded
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        }
        
        addToHistory(location: dataArray[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! LocationViewCell
        
        cell.companyName.text  = self.dataArray[indexPath.row].company
        if self.dataArray[indexPath.row].field != "" {
            cell.fieldName.text  = self.dataArray[indexPath.row].field
        } else {
            cell.fieldName.text  = "Field not found"
        }
        cell.LocationNameSmall.text = self.dataArray[indexPath.row].location
        cell.nearestCity.text = self.dataArray[indexPath.row].miles
        cell.locationCoordinates.text = "\(self.dataArray[indexPath.row].latitude), " +
                                            "\(self.dataArray[indexPath.row].longitude)"
        cell.locationName.text = self.dataArray[indexPath.row].location
        
        if((usersLocation) != nil) {
            let location = CLLocation(latitude: self.dataArray[indexPath.row].latitude,
                                      longitude: self.dataArray[indexPath.row].longitude)
            let distanceInMeters = location.distance(from: usersLocation!)
            let milesAway = Int(Float(distanceInMeters/1609).rounded())
            let milesAwayText = milesAway >= 1 ? "\(milesAway) miles away" : "<1 mile away"
            cell.nearestCity.text = milesAwayText
        } else {
            cell.nearestCity.text = "Unknown"
        }
        return cell
    }
    
    // MARK: Cell Displaying --------------------------------------------------------------------
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
}

import UIKit
import StoreKit

class SubscriptionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return IAPManager.sharedInstance.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let product = IAPManager.sharedInstance.products[indexPath.row]
        
        cell.textLabel?.text = product.localizedTitle + " - "
            + self.priceStringForProduct(product: product)
        
        cell.detailTextLabel?.text = product.localizedDescription
        cell.accessoryType = .none
        
        switch indexPath.row {
            case 0:
                cell.imageView?.image = UIImage(named: "package")
                break;
            case 1:
                cell.imageView?.image = UIImage(named: "advertising")
                break;
            case 2:
                cell.imageView?.image = UIImage(named: "shovel")
                break;
            default:
                break;
        }
        
        return cell
    }
    
    func priceStringForProduct(product:SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        
        return formatter.string(from: product.price)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.init(red: 241/255.0, green: 243/255.0, blue: 247/255.0, alpha: 1)
    }
}

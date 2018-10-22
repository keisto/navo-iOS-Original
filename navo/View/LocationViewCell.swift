import UIKit

class LocationViewCell: UITableViewCell {

    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var LocationNameSmall: UILabel!
    @IBOutlet weak var nearestCity: UILabel!
    @IBOutlet weak var locationCoordinates: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var fieldName: UILabel!
    @IBOutlet weak var backView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.clear
        
        self.backView.layer.borderWidth = 1
        self.backView.layer.cornerRadius = 3
        self.backView.layer.borderColor = UIColor.clear.cgColor
        self.backView.layer.masksToBounds = true
        
        self.layer.shadowOpacity = 0.18
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 2
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

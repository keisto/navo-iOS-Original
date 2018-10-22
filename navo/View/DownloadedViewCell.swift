import UIKit

class DownloadedViewCell: UITableViewCell {

    @IBOutlet weak var stateFlag: UIImageView!
    @IBOutlet weak var stateName: UILabel!
    @IBOutlet weak var stateStatus: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        stateFlag.layer.cornerRadius = 6
        stateFlag.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

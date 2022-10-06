import UIKit

protocol NotificationCellDelegate {
    func notificationDidPress(notification: NotificationModel)
}

class NotificationCell: UITableViewCell {
    
    
    @IBOutlet weak var entireCell: UIView!
    @IBOutlet weak var verticalLine: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var delegate: NotificationCellDelegate?
    var notificationID: String?
    var notificationRead: Bool = false
    var notifcationDate: String?
    var notificationArticle: Article?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setGestureRecognizers()
        setCellColorDesign()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

    
    func setCellColorDesign() {
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = bgColorView
    }
    

    func setGestureRecognizers() {
        entireCell.addGestureRecognizer(UITapGestureRecognizer(target: entireCell, action: #selector(notificationCellTapped)))
        entireCell.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(notificationCellTapped(tapGestureRecognizer:)))
        entireCell.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    @objc func notificationCellTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.notificationDidPress(
            notification: NotificationModel(
                text: label.text ?? "",
                wasRead: self.notificationRead,
                id: self.notificationID ?? "-1",
                date: self.notifcationDate ?? "",
                article: self.notificationArticle)
        )
    }
}

import UIKit

protocol CustomHeaderViewDelegate: AnyObject {
    
    func notificationsButtonPressed()
    func searchButtonPressed()
    func backButtonPressed()
    func checkmarkButtonPressed()
    func cancelButtonPressed()
}
extension CustomHeaderViewDelegate {
    
    func notificationsButtonPressed() {}
    func searchButtonPressed() {}
    func backButtonPressed() {}
    func checkmarkButtonPressed() {}
    func cancelButtonPressed() {}
}

enum HeaderTypes {
    case fullAppearance
    case backOnlyAppearance
    case confirmCancelAppearance
}

class CustomHeaderView: UIView {

    @IBOutlet weak var rightNotificationsImageView: UIImageView!
    @IBOutlet weak var rightSearchImageView: UIImageView!
    @IBOutlet weak var rightConfirmImageView: UIImageView!
    @IBOutlet weak var leftLogoImageView: UIImageView!
    @IBOutlet weak var leftGoBackImageView: UIImageView!
    @IBOutlet weak var leftCancelImageView: UIImageView!
    @IBOutlet var contentView: UIView!
    
    private weak var delegate: CustomHeaderViewDelegate?

    
    func initView(delegate: CustomHeaderViewDelegate? = nil, apperanceType: HeaderTypes) {
        commonInit()
        hideAllElements()
        determineHeaderAppearance(apperanceType)
        if let safeDelegate = delegate {
            self.delegate = safeDelegate
        }
    }
    

    
    private func commonInit() {
        Bundle.main.loadNibNamed("CustomHeaderView", owner: self, options: nil)
        contentView.frame = self.bounds
        self.addSubview(contentView)
    }
    

    private func hideAllElements() {
        rightNotificationsImageView.isHidden = true
        rightSearchImageView.isHidden = true
        rightConfirmImageView.isHidden = true
        leftLogoImageView.isHidden = true
        leftGoBackImageView.isHidden = true
        leftCancelImageView.isHidden = true
    }
    

    private func determineHeaderAppearance(_ apperanceType: HeaderTypes) {
        switch apperanceType {
        case .fullAppearance:
            setLogoAndRightButtons()
            setNotificationsObserver()
        case .backOnlyAppearance:
            setBackButtonOnly()
        case .confirmCancelAppearance:
            setCheckAndCancelButtons()
        }
    }
    

    func setLogoAndRightButtons() {
        //logo          search  notifications
        rightNotificationsImageView.isHidden = false
        rightNotificationsImageView.addGestureRecognizer(UITapGestureRecognizer(target: rightNotificationsImageView, action: #selector(notificationsButtonPressed)))
        rightNotificationsImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(notificationsButtonPressed(tapGestureRecognizer:)))
        rightNotificationsImageView.addGestureRecognizer(tapGestureRecognizer1)
        
        rightSearchImageView.image = UIImage(named: "search")
        rightSearchImageView.isHidden = false
        rightSearchImageView.addGestureRecognizer(UITapGestureRecognizer(target: rightSearchImageView, action: #selector(searchButtonPressed)))
        rightSearchImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(searchButtonPressed(tapGestureRecognizer:)))
        rightSearchImageView.addGestureRecognizer(tapGestureRecognizer2)

        leftLogoImageView.isHidden = false
    }
    
    func setNotificationsObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.displayGotNotification), name: NSNotification.Name(rawValue: Constants.NotificationCenter.NOTIFICATION_RECIVED), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.displayNoNotification), name: NSNotification.Name(rawValue: Constants.NotificationCenter.NO_MORE_NOTIFICATIONS), object: nil)
    }
    

    func setBackButtonOnly() {
        //back
        leftGoBackImageView.isHidden = false
        leftGoBackImageView.addGestureRecognizer(UITapGestureRecognizer(target: leftGoBackImageView, action: #selector(backButtonPressed)))
        leftGoBackImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backButtonPressed(tapGestureRecognizer:)))
        leftGoBackImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    

    func setCheckAndCancelButtons() {
        //cancel            confirm
        rightConfirmImageView.image = UIImage(named: "checkmark")
        rightConfirmImageView.isHidden = false
        rightConfirmImageView.addGestureRecognizer(UITapGestureRecognizer(target: rightConfirmImageView, action: #selector(checkmarkButtonPressed)))
        rightConfirmImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(checkmarkButtonPressed(tapGestureRecognizer:)))
        rightConfirmImageView.addGestureRecognizer(tapGestureRecognizer1)
        
        leftCancelImageView.image = UIImage(named: "close")
        leftCancelImageView.isHidden = false
        leftCancelImageView.addGestureRecognizer(UITapGestureRecognizer(target: leftCancelImageView, action: #selector(cancelButtonPressed)))
        leftCancelImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(cancelButtonPressed(tapGestureRecognizer:)))
        leftCancelImageView.addGestureRecognizer(tapGestureRecognizer2)
    }
    
    
    @objc func displayGotNotification() {
        DispatchQueue.main.async {
            self.rightNotificationsImageView.image = UIImage(named: "notification-with-dot")
        }
    }
    
    @objc func displayNoNotification() {
        DispatchQueue.main.async {
            self.rightNotificationsImageView.image = UIImage(named: "notifications")
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }


    func updateHeaderAppearanceType(to appearanceType: HeaderTypes) {
        hideAllElements()
        determineHeaderAppearance(appearanceType)
    }
    
 
    @objc func notificationsButtonPressed(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.notificationsButtonPressed()
    }
  
    @objc func searchButtonPressed(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.searchButtonPressed()
    }

    @objc func backButtonPressed(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.backButtonPressed()
    }

    @objc func checkmarkButtonPressed(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.checkmarkButtonPressed()
    }

    @objc func cancelButtonPressed(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.cancelButtonPressed()
    }
}

import UIKit

protocol ActionPopupViewDelegate {
    func cameraButtonPressed()
    func galleryButtonPressed()
    func okButtonPressed()
}
extension ActionPopupViewDelegate {
    func cameraButtonPressed() {}
    func galleryButtonPressed() {}
    func okButtonPressed() {}
}

enum popupViewActionLook {
    case selectPictureFrom
    case confirmAlert
}

class ActionPopupView: UIView {
    
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var popupText: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    
    var delegate: ActionPopupViewDelegate?
    
    func initView(delegate: ActionPopupViewDelegate? = nil) {
        
        self.delegate = delegate
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ActionPopupView", owner: self, options: nil)
        contentView.frame = self.bounds
        self.addSubview(contentView)
    }
    
    func reArrangePopupView(toState: popupViewActionLook) {
        
        switch toState {
        case .selectPictureFrom:
            popupTitle.text = "Profile Picture"
            popupText.text = "Upload new image for your personal Icon"
            rightButton.setTitle("Camera", for: .normal) // TO DO : use texts from constants
            leftButton.isHidden = false
        case .confirmAlert:
            popupTitle.text = "Profile edit"
            popupText.text = "Your changes has been updated"
            rightButton.setTitle("OK", for: .normal) // TO DO : use texts from constants
            leftButton.isHidden = true
        }
    }
    
    
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        if rightButton.currentTitle == "OK" {  // TO DO : put in constants as "confirmText"
            delegate?.okButtonPressed()
        } else {
            print("i know its camera")
            delegate?.cameraButtonPressed()
        }
    }

    
    @IBAction func leftButtonPressed(_ sender: UIButton) {
        delegate?.galleryButtonPressed()
    }
}

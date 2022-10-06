import UIKit

protocol MainActionButtonDelegate {
    func actionButtonDidPress(btnText: String)
}

class MainActionButtonView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var entireButton: UIView!
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var buttonIcon: UIImageView!
    
    var delegate: MainActionButtonDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame = self.bounds
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("MainActionButtonView", owner: self, options: nil)
        addSubview(contentView)
        
        contentView.layer.cornerRadius = contentView.frame.size.height / 2
        contentView.clipsToBounds = true
        
        setGestureRecognizer()
    }
    

    
    func setGestureRecognizer() {
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: contentView, action: #selector(buttonTapped)))
        contentView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(buttonTapped(tapGestureRecognizer:)))
        contentView.addGestureRecognizer(tapGestureRecognizer)
    }
    

    @objc func buttonTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.actionButtonDidPress(btnText: buttonLabel.text!)
    }
}

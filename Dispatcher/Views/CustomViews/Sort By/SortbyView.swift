import UIKit

protocol SortbyViewDelegate {
    func filterIconDidPress()
}

class SortbyView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var filterIcon: UIImageView!
    
    var delegate: SortbyViewDelegate?
    
    
    func initView(delegate: SortbyViewDelegate? = nil) {
        
        self.delegate = delegate
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("SortbyView", owner: self, options: nil)
        contentView.frame = self.bounds
        self.addSubview(contentView)
    }
    
    func setGestureRecognizers() {
        filterIcon.addGestureRecognizer(UITapGestureRecognizer(target: filterIcon, action: #selector(filterButtonPressed)))
        filterIcon.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(filterButtonPressed(tapGestureRecognizer:)))
        filterIcon.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func filterButtonPressed(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.filterIconDidPress()
    }
}

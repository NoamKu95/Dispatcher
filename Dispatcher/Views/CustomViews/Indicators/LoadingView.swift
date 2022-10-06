import UIKit

protocol LoadingViewDelegate {}

class LoadingView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    
    var delegate: LoadingViewDelegate?
    

    func initView(delegate: LoadingViewDelegate? = nil) {
        self.delegate = delegate
        commonInit()
    }
    

    private func commonInit() {
        Bundle.main.loadNibNamed("LoadingView", owner: self, options: nil)
        contentView.frame = self.bounds
        self.addSubview(contentView)
        
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
    }
}

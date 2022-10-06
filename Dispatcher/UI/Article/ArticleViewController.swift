import UIKit

class ArticleViewController: UIViewController {

    
    @IBOutlet weak var customHeader: CustomHeaderView!
    
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var inarticleImage: UIImageView!
    
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var topicButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var topContentLabel: UILabel!
    @IBOutlet weak var bottomContentLabel: UILabel!
    
    
    let articleVM = ArticleViewModel()
    let cameFrom: String! = Constants.ScreenNames.HOMEPAGE
    var currentArticle = Article(id: "", articleTitle: "", date: "", url: "", content: "", author: "", topic: "", imageUrl: "", isFavorite: false)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initiateUIElements()
        setGestureRecognizer()
    }
    
    func initiateUIElements() {
        customHeader.initView(delegate: self, apperanceType: .backOnlyAppearance)
        dateLabel.text = currentArticle.date
        titleLabel.text = currentArticle.articleTitle
        authorLabel.text = currentArticle.author
        topContentLabel.text = currentArticle.content
        bottomContentLabel.text = currentArticle.content
        topicButton.setTitle(currentArticle.topic, for: .normal)
        if currentArticle.isFavorite {
            favoriteIcon.image = UIImage(named: "favoriteArticle-selected")
        }
        guard let url = URL(string: currentArticle.imageUrl!) else { return }
        UIImage.loadFrom(url: url) { image in
            self.articleImage.image = image
            self.inarticleImage.image = image
        }
    }
    
    
    func setGestureRecognizer() {
        favoriteIcon.addGestureRecognizer(UITapGestureRecognizer(target: favoriteIcon, action: #selector(favoriteIconPressed)))
        favoriteIcon.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(favoriteIconPressed(tapGestureRecognizer:)))
        favoriteIcon.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    @objc func favoriteIconPressed(tapGestureRecognizer: UITapGestureRecognizer) {
        
        if currentArticle.isFavorite {
            articleVM.removeArticleFromFavorites(articleID: currentArticle.id) {
                self.currentArticle.isFavorite = false
                let dataDict:[String: String] = [
                    Constants.NotificationCenter.ARTICLE_ID: self.currentArticle.id,
                    Constants.NotificationCenter.IS_FAVORITE: "\(!self.currentArticle.isFavorite)",
                    Constants.NotificationCenter.SENDER: Constants.NotificationCenter.SENDER_ARTICLE
                ]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenter.ARTICLE_TO_TABLES), object: nil, userInfo: dataDict)
                DispatchQueue.main.async {
                    self.favoriteIcon.image = UIImage(named: "favoriteArticle-notSelected")
                }
            }
        } else {
            self.currentArticle.isFavorite = true
            articleVM.addArticleToFavorites(newArticle: currentArticle) {
                let dataDict:[String: String] = [
                    Constants.NotificationCenter.ARTICLE_ID: self.currentArticle.id,
                    Constants.NotificationCenter.IS_FAVORITE: "\(!self.currentArticle.isFavorite)",
                    Constants.NotificationCenter.SENDER: Constants.NotificationCenter.SENDER_ARTICLE
                ]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenter.ARTICLE_TO_TABLES), object: nil, userInfo: dataDict)
                DispatchQueue.main.async {
                    self.favoriteIcon.image = UIImage(named: "favoriteArticle-selected")
                }
            }
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        setStatusBarColor(viewController: self, hexColor: "262146")
    }
}

// MARK: - CustomHeaderViewDelegate
extension ArticleViewController: CustomHeaderViewDelegate {
    
    func backButtonPressed() {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}

import UIKit

protocol NewsCellDelegate {
    func favoriteIconDidPress(forArticle article: Article)
    func actionButtonDidPress(inside article: Article)
}

enum ArticleFavoriteMark {
    case selected
    case notSelected
}

class NewsCell: UITableViewCell, MainActionButtonDelegate {

    @IBOutlet weak var entireNewsCell: UIView!
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var favoriteIcon: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subjectTag: UIButton!
    @IBOutlet weak var moreSubjectsTag: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var actionButton: MainActionButtonView!
    
    
    var delegate: NewsCellDelegate?
    var articleUrl = ""
    var articleID = ""
    var articleImageUrl = ""
    var isFavorite: Bool = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setCellBorder()
        setCellColorsDesign()
        setImageRounded()
        setTagsRounded()
        setGestureRecognizer()
        
        actionButton.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))

        self.contentView.layoutIfNeeded()
        self.layoutIfNeeded()
    }
    
    

    func setCellBorder() {
        entireNewsCell.layer.cornerRadius = 20
        entireNewsCell.layer.borderWidth = 2
        let borderColor = UIColor( red: 243/255, green: 243/255, blue:255/255, alpha: 1.0 )
        entireNewsCell.layer.borderColor = borderColor.cgColor
    }
    
    
    func setCellColorsDesign() {
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = bgColorView
    }
    
    
    func setImageRounded() {
        newsImage.clipsToBounds = true
        newsImage.layer.cornerRadius = 10
        newsImage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    

    func setTagsRounded() {
        subjectTag.layer.cornerRadius = subjectTag.frame.size.height / 2
        subjectTag.clipsToBounds = true
        moreSubjectsTag.layer.cornerRadius = moreSubjectsTag.frame.size.height / 2
        moreSubjectsTag.clipsToBounds = true
    }
    

    func setGestureRecognizer() {
        favoriteIcon.addGestureRecognizer(UITapGestureRecognizer(target: favoriteIcon, action: #selector(favoriteIconPressed)))
        favoriteIcon.isUserInteractionEnabled = true
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(favoriteIconPressed(tapGestureRecognizer:)))
        favoriteIcon.addGestureRecognizer(tapGestureRecognizer1)
    }
    
    
    @objc func favoriteIconPressed(tapGestureRecognizer: UITapGestureRecognizer) {
        let currentArticle = Article(id: articleID, articleTitle: titleLabel.text!, date: dateLabel.text ?? "", url: articleUrl, content: summaryLabel.text!, author: authorLabel.text ?? "", topic: subjectTag.currentTitle!, imageUrl: articleImageUrl , isFavorite: isFavorite)
        delegate?.favoriteIconDidPress(forArticle: currentArticle)
    }
    
    
    func actionButtonDidPress(btnText: String) {
        let currentArticle = Article(
            id: articleID,
            articleTitle: titleLabel.text ?? "",
            date: dateLabel.text ?? "",
            url: articleUrl,
            content: summaryLabel.text ?? "",
            author: authorLabel.text ?? "",
            topic: subjectTag.currentTitle ?? "",
            imageUrl: articleImageUrl,
            isFavorite: self.isFavorite)

        delegate?.actionButtonDidPress(inside: currentArticle)
    }
}

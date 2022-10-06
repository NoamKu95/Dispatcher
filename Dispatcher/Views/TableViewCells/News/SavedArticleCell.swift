import UIKit

protocol SavedArticleCellDelegate {
    func favoriteIconDidPress(forArticle: String)
    func cellDidPress(articleID: String)
}

class SavedArticleCell: UITableViewCell {
    
    @IBOutlet weak var savedArticleCell: UIView!
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleTopic: UIButton!
    @IBOutlet weak var articleMoreTags: UIButton!
    
    var delegate: SavedArticleCellDelegate?
    var articleID = ""
    var articleUrl = ""
    var articleImageURL = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        setCellBorder()
        setCellColorsDesign()
        setImageRounded()
        setTagsRounded()
        setGestureRecognizer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
    }

    
    
    func setCellBorder() {
        savedArticleCell.layer.borderWidth = 2
        let borderColor = UIColor( red: 243/255, green: 243/255, blue:255/255, alpha: 1.0 )
        savedArticleCell.layer.borderColor = borderColor.cgColor
        savedArticleCell.layer.cornerRadius =  4
    }
    
    
    func setCellColorsDesign() {
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = bgColorView
    }
    
    
    func setImageRounded() {
        articleImage.clipsToBounds = true
        articleImage.layer.cornerRadius = 4
        articleImage.layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMinXMinYCorner,
            .layerMaxXMaxYCorner,
            .layerMaxXMinYCorner
        ]
    }
    
    
    func setTagsRounded() {
        articleTopic.layer.cornerRadius = articleTopic.frame.size.height / 2
        articleTopic.clipsToBounds = true
        articleMoreTags.layer.cornerRadius = articleMoreTags.frame.size.height / 2
        articleMoreTags.clipsToBounds = true
    }
    

    func setGestureRecognizer() {
        favoriteIcon.addGestureRecognizer(UITapGestureRecognizer(target: favoriteIcon, action: #selector(favoriteIconPressed)))
        favoriteIcon.isUserInteractionEnabled = true
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(favoriteIconPressed(tapGestureRecognizer:)))
        favoriteIcon.addGestureRecognizer(tapGestureRecognizer1)
        
        savedArticleCell.addGestureRecognizer(UITapGestureRecognizer(target: savedArticleCell, action: #selector(cellPressed)))
        savedArticleCell.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellPressed(tapGestureRecognizer:)))
        savedArticleCell.addGestureRecognizer(tapGestureRecognizer)
    }
    

    @objc func favoriteIconPressed(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.favoriteIconDidPress(forArticle: articleID)
    }
    
    
    @objc func cellPressed(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.cellDidPress(articleID: articleID)
    }
}

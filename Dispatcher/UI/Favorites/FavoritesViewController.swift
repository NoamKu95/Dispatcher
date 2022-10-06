import UIKit

class FavoritesViewController: UIViewController, UITableViewDelegate, LoadingViewDelegate {
    
    @IBOutlet weak var customHeader: CustomHeaderView!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noResultsImageView: UIImageView!
    @IBOutlet weak var noResultsLabel: UILabel!
    
    let viewModel = BaseArticlesViewModel()
    var dataSource: TableViewDataSourceManager<FavoriteArticle>!
    var isPaginating: Bool = false
    var selectedArticle: Article? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        defineNotificationCenterListeners()
        initiateUIElements()
        displaySavedArticlesOnScreen()
    }
    

    func defineNotificationCenterListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTableViewContent), name: NSNotification.Name(rawValue: Constants.NotificationCenter.HOMEPAGE_TO_FAVORITES), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTableViewContent), name: NSNotification.Name(rawValue: Constants.NotificationCenter.ARTICLE_TO_TABLES), object: nil)
    }
    

    @objc func refreshTableViewContent(_ notification: NSNotification) {
        viewModel.getSavedArticles {
            DispatchQueue.main.async {
                if self.viewModel.savedArticles.count == 0 {
                    self.displayNoResults()
                } else {
                    self.hideNoResults()
                    self.tableView.reloadData()
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                    self.tableView.layoutIfNeeded()
                }
            }
        }
    }
    

    func initiateUIElements() {
        customHeader.initView(delegate: self, apperanceType: .fullAppearance)
        loadingView.initView(delegate: self)
        hideNoResults()
        setupTableView()
    }
    

    func setupTableView() {
        tableView.register(UINib(nibName: Constants.NibNames.FAVORITES, bundle: nil), forCellReuseIdentifier: Constants.TableCellsIdentifier.FAVORITES)
        tableView.delegate = self
        tableView.dataSource = self
    }
    

    func displaySavedArticlesOnScreen() {
        displayLoadingAnimation()
        viewModel.getSavedArticles() {
            if self.viewModel.savedArticles.count == 0 {
                self.displayNoResults()
            } else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            self.removeLoadingAnimation()
        }
    }
    

    func displayNoResults() {
        self.tableView.isHidden = true
        self.noResultsLabel.isHidden = false
        self.noResultsImageView.isHidden = false
    }
    

    func hideNoResults() {
        self.tableView.isHidden = false
        self.noResultsLabel.isHidden = true
        self.noResultsImageView.isHidden = true
    }
    

    func displayLoadingAnimation() {
        DispatchQueue.main.async {
            self.loadingView.loadIndicator.startAnimating()
            self.loadingView.isHidden = false
        }
    }
    

    func removeLoadingAnimation() {
        DispatchQueue.main.async {
            self.loadingView.loadIndicator.stopAnimating()
            self.loadingView.isHidden = true
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        setStatusBarColor(viewController: self, hexColor: "262146")
    }
}

// MARK: - CustomHeaderViewDelegate
extension FavoritesViewController: CustomHeaderViewDelegate {
    
    func notificationsButtonPressed() {
        self.performSegue(withIdentifier: Constants.Segues.FAVORITES_TO_NOTIFICATIONS, sender: self)
    }
    

    func searchButtonPressed() {
        self.performSegue(withIdentifier: Constants.Segues.FAVORITES_TO_SEARCH, sender: self)
    }
}

// MARK: - SavedArticleCellDelegate
extension FavoritesViewController: SavedArticleCellDelegate {
    
    func cellDidPress(articleID: String) {
        let favorite = viewModel.savedArticles[articleID]
        if let favorite = favorite {
            selectedArticle = Article(id: favorite.id!, articleTitle: favorite.title!, date: favorite.date!, url: favorite.url!, content: favorite.content!, author: favorite.author!, topic: favorite.topic!, imageUrl: favorite.imageUrl!, isFavorite: true)
            self.performSegue(withIdentifier: Constants.Segues.FAVORITES_TO_ARTICLE, sender: self)
        }
    }
    
    override func prepare( for segue: UIStoryboardSegue, sender: Any? ) {
        if let selectedArticle = selectedArticle {
            if segue.identifier == Constants.Segues.FAVORITES_TO_ARTICLE {
                let destinationVC = segue.destination as! ArticleViewController
                destinationVC.currentArticle = selectedArticle
            }
        }
    }
    
    
    func favoriteIconDidPress(forArticle articleID: String) {
        displayLoadingAnimation()
        viewModel.removeArticleFromFavorites(articleID: articleID) { error, _ in
            if let error = error {
                print(error)
                self.removeLoadingAnimation()
            } else {
                DispatchQueue.main.async {
                    if self.viewModel.savedArticles.count == 0 {
                        self.displayNoResults()
                    } else {
                        self.tableView.reloadData()
                    }
                    let dataDict:[String: String] = [
                        Constants.NotificationCenter.ARTICLE_ID: articleID,
                        Constants.NotificationCenter.SENDER: Constants.NotificationCenter.SENDER_FAVORITES
                    ]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenter.FAVORITES_TO_HOMEPAGE), object: nil, userInfo: dataDict)
                    self.removeLoadingAnimation()
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension FavoritesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.savedArticles.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellsIdentifier.FAVORITES, for: indexPath) as! SavedArticleCell
        currentCell.delegate = self
        
        let currentKey = viewModel.keysArray[indexPath.row]
        let savedArticle = viewModel.savedArticles[currentKey]
        
        if let savedArticle = savedArticle {
            currentCell.articleID = savedArticle.id!
            currentCell.articleTitle.text = savedArticle.title
            currentCell.articleTopic.setTitle(savedArticle.topic, for: .normal)
            
            if let imageUrl = savedArticle.imageUrl {
                currentCell.articleImageURL = imageUrl
                currentCell.articleImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "light-gray-background"))
            } else {
                currentCell.articleImage.image = UIImage(named: "light-gray-background")
            }
        }
        
        return currentCell
    }
}

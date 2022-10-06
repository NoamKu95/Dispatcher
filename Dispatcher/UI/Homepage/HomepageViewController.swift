import UIKit
import CoreData
import SDWebImage

class HomepageViewController: UIViewController, LoadingViewDelegate {

    @IBOutlet weak var customHeader: CustomHeaderView!
    @IBOutlet weak var sortbyView: SortbyView!
    @IBOutlet weak var lastLoginLabel: UILabel!
    @IBOutlet weak var lastLoginTimestampLabel: UILabel!
    @IBOutlet weak var topHeadlinesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    
    let viewModel = BaseArticlesViewModel()
    var dataSource: TableViewDataSourceManager<Article>!
    var isPaginating: Bool = false
    var selectedArticle: Article? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        defineNotificationCenterListeners()
        initiateUIElements()
        getLastLoginTimestamp()
        checkUserSettingsPreferences()
        viewModel.getSavedArticles() {
            self.fetchInitialNewsResults()
        }
        setupTableView()
    }
    
    
    
    func defineNotificationCenterListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTableViewContent), name: NSNotification.Name(rawValue: Constants.NotificationCenter.FAVORITES_TO_HOMEPAGE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTableViewContent), name: NSNotification.Name(rawValue: Constants.NotificationCenter.ARTICLE_TO_TABLES), object: nil)
    }
    
    
    @objc func refreshTableViewContent(_ notification: NSNotification) {

        if notification.userInfo![Constants.NotificationCenter.SENDER] as! String == Constants.NotificationCenter.SENDER_FAVORITES {
            viewModel.updateArticleToNotFavoriteLocally(articleID: notification.userInfo![Constants.NotificationCenter.ARTICLE_ID] as! String) { _ in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } else {
            if notification.userInfo![Constants.NotificationCenter.IS_FAVORITE] as! String == "true" {
                viewModel.updateArticleToNotFavoriteLocally(articleID: notification.userInfo![Constants.NotificationCenter.ARTICLE_ID] as! String) { _ in
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } else {
                viewModel.updateArticleToYesFavoriteLocally(articleID: notification.userInfo![Constants.NotificationCenter.ARTICLE_ID] as! String) {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    func initiateUIElements() {
        customHeader.initView(delegate: self, apperanceType: .fullAppearance)
        sortbyView.initView(delegate: self)
        loadingView.initView(delegate: self)
    }
    
    
    func getLastLoginTimestamp() {
        if let lastLogin = viewModel.getUserLastLoginTimestamp() {
            lastLoginTimestampLabel.text = lastLogin
        } else {
            lastLoginLabel.isHidden = true
            lastLoginTimestampLabel.isHidden = true
        }
    }
    
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: Constants.NibNames.HOMEPAGE, bundle: nil), forCellReuseIdentifier: Constants.TableCellsIdentifier.HOMEPAGE)
    }
    
    
    func checkUserSettingsPreferences() {
        print("SAVE_FILTERS app setting is: \(viewModel.getUserAppSetting(of: Constants.UserDefaults.SAVE_FILTERS))")
        print("SEND_NOTIFICATIONS app setting is: \(viewModel.getUserAppSetting(of: Constants.UserDefaults.SEND_NOTIFICATIONS))")
    }
    
    
    @objc func fetchInitialNewsResults() {
        DispatchQueue.main.async {
            self.loadingView.isHidden = false
            self.loadingView.loadIndicator.startAnimating()
        }
        viewModel.fetchNewsFromAPI(pageSizeToFetch: .articlesList) { error, _ in
            if let error = error {
                print("Error fetching News: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            DispatchQueue.main.async {
                self.loadingView.loadIndicator.stopAnimating()
                self.loadingView.isHidden = true
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
extension HomepageViewController: CustomHeaderViewDelegate {
    
    func notificationsButtonPressed() {
        self.performSegue(withIdentifier: Constants.Segues.HOMEPAGE_TO_NOTIFICATIONS, sender: self)
    }
    
    
    func searchButtonPressed() {
        self.performSegue(withIdentifier: Constants.Segues.HOMEPAGE_TO_SEARCH, sender: self)
    }
}

// MARK: - UIScrollViewDelegate
extension HomepageViewController: UIScrollViewDelegate {
    
    func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        
        return footerView
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - 100 - scrollView.frame.size.height) && !isPaginating {

            isPaginating = true
            viewModel.fetchNewsFromAPI(pageSizeToFetch: .articlesList) { error, numArticlesFetched in
                if let error = error {
                    print(error)
                } else {
                    DispatchQueue.main.async {
                        if numArticlesFetched != 0 {
                            self.tableView.beginUpdates()
                            var indexPaths = [IndexPath]()
                            let originalLastIndex = self.viewModel.newsArray.count - 1 - numArticlesFetched!
                            let newLastIndex = self.viewModel.newsArray.count - 1
                            for i in originalLastIndex...(newLastIndex - 1) {
                                indexPaths.append(IndexPath(row: i, section: 0))
                            }
                            self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                            self.tableView.endUpdates()
                        }
                        self.tableView.tableFooterView = nil
                    }
                }
                self.isPaginating = false
            }
        }
    }
}

// MARK: - NewsCellDelegate
extension HomepageViewController: NewsCellDelegate {
    
    func actionButtonDidPress(inside article: Article) {
        selectedArticle = article
        self.performSegue(withIdentifier: Constants.Segues.HOMEPAGE_TO_ARTICLE, sender: self)
    }
    
    
    override func prepare( for segue: UIStoryboardSegue, sender: Any? ) {
        if let selectedArticle = selectedArticle {
            if segue.identifier == Constants.Segues.HOMEPAGE_TO_ARTICLE {
                let destinationVC = segue.destination as! ArticleViewController
                destinationVC.currentArticle = selectedArticle
            }
        }
    }
    
    
    func favoriteIconDidPress(forArticle article: Article) {
        if article.isFavorite {
            viewModel.removeArticleFromFavorites(articleID: article.id, completionHandler: handleFavoritesUpdate)
        } else {
            viewModel.addArticleToFavorites(article, completionHandler: handleFavoritesUpdate)
        }
    }
    
    
    func handleFavoritesUpdate(error: String?, index: Int?) {
        if let error = error {
            print(error)
        } else {
            DispatchQueue.main.async {
                if let index = index {
                    self.tableView.beginUpdates()
                    let indexPath = IndexPath(row: index, section: 0 )
                    self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                    self.tableView.endUpdates()
                } else {
                    self.tableView.reloadData()
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenter.HOMEPAGE_TO_FAVORITES), object: nil)
        }
    }
}

// MARK: - SortbyViewDelegate
extension HomepageViewController: SortbyViewDelegate {
    
    func filterIconDidPress() {
        print("Filter pane pressed")
    }
}

// MARK: - UITableViewDelegate
extension HomepageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension HomepageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 436
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.newsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellsIdentifier.HOMEPAGE, for: indexPath) as! NewsCell
        
        currentCell.delegate = self

        currentCell.articleID = viewModel.newsArray[indexPath.row].id
        
        if let imageUrl = viewModel.newsArray[indexPath.row].imageUrl {
            currentCell.articleImageUrl = imageUrl
            currentCell.newsImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "light-gray-background"))
        } else {
            currentCell.newsImage.image = UIImage(named: "light-gray-background")
        }
        
        currentCell.titleLabel.text = viewModel.newsArray[indexPath.row].articleTitle
        currentCell.authorLabel.text = viewModel.newsArray[indexPath.row].author
        currentCell.summaryLabel.text = viewModel.newsArray[indexPath.row].content
        currentCell.subjectTag.setTitle(viewModel.newsArray[indexPath.row].topic, for: .normal)
        currentCell.articleUrl = viewModel.newsArray[indexPath.row].url
        if let date = adaptDateTimeFormat(currentFormat: "yyyy-MM-dd HH:mm:ss", desiredFormat: "EEEE MMM d, yyyy", timestampToAdapt: viewModel.newsArray[indexPath.row].date) {
            currentCell.dateLabel.text = date
        } else {
            currentCell.dateLabel.text = viewModel.newsArray[indexPath.row].date
        }
        if viewModel.newsArray[indexPath.row].isFavorite {
            currentCell.isFavorite = true
            currentCell.favoriteIcon.image = UIImage(named: "favoriteArticle-selected")
        } else {
            currentCell.isFavorite = false
            currentCell.favoriteIcon.image = UIImage(named: "favoriteArticle-notSelected")
        }
        
        return currentCell
    }
}

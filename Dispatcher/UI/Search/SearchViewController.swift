import UIKit

enum iconImageName {
    case search
    case remove
}

class SearchViewController: UIViewController, LoadingViewDelegate {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchClearIcon: UIImageView!
    @IBOutlet weak var goBackButton: UIImageView!
    
    @IBOutlet weak var recentSearchesView: UIView!
    @IBOutlet weak var recentSearchesTableView: UITableView!
    
    @IBOutlet weak var sortbyView: SortbyView!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    @IBOutlet weak var noResultsImageView: UIImageView!
    @IBOutlet weak var noResultsLabel: UILabel!
    
    @IBOutlet weak var loadingView: LoadingView!
    
    
    let viewModel = SearchViewModel()
    
    var selectedArticle: Article? = nil
    var searchClearImageName: iconImageName = .search
    var isPaginating: Bool = false
    var isSaveSearches: Bool = true
    var recentSearchesDataSource: TableViewDataSourceManager<RecentSearchModel>!
    var searchResultsDataSource: TableViewDataSourceManager<Article>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.getSavedArticles() {}
        checkUserPreference()
        initiateUIElements()
        defineGestureRecognizers()
        defineNotificationCenterListeners()
    }
    

    func checkUserPreference() {
        if viewModel.isSaveRecentSearches() {
            fetchSearchHistory() {}
        } else {
            isSaveSearches = false
        }
    }

    
    func fetchSearchHistory(completionHandler: @escaping () -> ()) {
        viewModel.getSavedRecentSearchesFromUserDefaults() { error in
            if let error = error {
                print(error)
            }
            completionHandler()
        }
    }
    

    func initiateUIElements() {
        setStatusBarColor(viewController: self, hexColor: "FFFFFF")
        setupTextField()
        setupTableViews()
        initialHideShowElements()
    }
    

    func setupTextField() {
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(SearchViewController.textFieldDidChange(_:)), for: .editingChanged)
    }
    

    func setupTableViews() {
        recentSearchesTableView.register(UINib(nibName: Constants.NibNames.RECENT_SEARCH, bundle: nil), forCellReuseIdentifier: Constants.TableCellsIdentifier.RECENT_SEARCH)
        self.recentSearchesDataSource = TableViewDataSourceManager(
            models: viewModel.recentSearchesArray,
            reuseIdentifier: Constants.TableCellsIdentifier.RECENT_SEARCH
        ) { search, cell in
            let currentcell = cell as! RecentSearchCell
            currentcell.delegate = self
            currentcell.label.text = search.text
        }
        recentSearchesTableView.dataSource = recentSearchesDataSource
        
        
        searchResultsTableView.register(UINib(nibName: Constants.NibNames.HOMEPAGE, bundle: nil), forCellReuseIdentifier: Constants.TableCellsIdentifier.HOMEPAGE)
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
    }
    
 
    func initialHideShowElements() {
        loadingView.initView(delegate: self)
        loadingView.isHidden = true
        sortbyView.initView(delegate: self)
        sortbyView.isHidden = true
        searchResultsTableView.isHidden = true
        hideNoSearchResults()
    }
    

    func defineGestureRecognizers() {
        goBackButton.addGestureRecognizer(UITapGestureRecognizer(target: goBackButton, action: #selector(goBackButtonPressed)))
        goBackButton.isUserInteractionEnabled = true
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(goBackButtonPressed(tapGestureRecognizer:)))
        goBackButton.addGestureRecognizer(tapGestureRecognizer1)
        
        searchClearIcon.addGestureRecognizer(UITapGestureRecognizer(target: searchClearIcon, action: #selector(searchClearButtonPressed)))
        searchClearIcon.isUserInteractionEnabled = true
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(searchClearButtonPressed(tapGestureRecognizer:)))
        searchClearIcon.addGestureRecognizer(tapGestureRecognizer2)
    }
    
    
    func defineNotificationCenterListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshRecentSearchesTable), name: NSNotification.Name(rawValue: Constants.NotificationCenter.RECENT_SEARCHES_EMPTIED), object: nil)
    }

    @objc func refreshRecentSearchesTable() {
        fetchSearchHistory() {
            DispatchQueue.main.async {
                self.recentSearchesDataSource.models = self.viewModel.recentSearchesArray
                self.recentSearchesTableView.reloadData()
            }
        }
    }
    
    
    func cleanTextFromSpecialCharacters(text: String) -> String {
        var cleanSearchWords = text
        let removeCharacters: Set<Character> = [".", "\"", ",", "?", "!", "@", "#", "$", "%", "^", "&", "*"]
        cleanSearchWords.removeAll(where: { removeCharacters.contains($0) } )
        return cleanSearchWords
    }

    
    func fetchInitialSearchResults(of keywords: String) {
        displayLoadingAnimation()
        self.recentSearchesView.isHidden = true
        self.recentSearchesTableView.isHidden = true
        self.sortbyView.isHidden = false
        
        viewModel.newsArray = []
        let cleanSearchWords = cleanTextFromSpecialCharacters(text: keywords.lowercased())
        viewModel.fetchNewsFromAPI(searchWords: cleanSearchWords, pageSizeToFetch: .articlesList) { error, _ in
            if let error = error {
                print(error)
            }
            
            if self.viewModel.newsArray.count == 0 {
                self.searchResultsTableView.isHidden = true
                self.displayNoSearchResults()
                self.removeLoadingAnimation()
            } else {
                self.hideNoSearchResults()
                self.searchResultsTableView.isHidden = false
                self.searchResultsTableView.reloadData()
                self.searchResultsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                
                if self.isSaveSearches {
                    self.viewModel.saveNewRecentSearch(self.cleanTextFromSpecialCharacters(text: keywords.lowercased())) {
                        DispatchQueue.main.async {
                            self.recentSearchesDataSource.models = self.viewModel.recentSearchesArray
                            self.recentSearchesTableView.reloadData()
                        }
                    }
                }
                self.removeLoadingAnimation()
                self.searchTextField.text = "\"\(self.cleanTextFromSpecialCharacters(text: self.searchTextField.text!.uppercased()))\""
            }
        }
    }
    

    @objc func goBackButtonPressed(tapGestureRecognizer: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: false)
    }
    

    @IBAction func clearRecentSearchesPressed(_ sender: UIButton) {
        displayLoadingAnimation()
        viewModel.clearRecentSearchesHistory() {
            self.recentSearchesDataSource.models = self.viewModel.recentSearchesArray
            DispatchQueue.main.async {
                self.recentSearchesTableView.reloadData()
            }
            self.removeLoadingAnimation()
        }
    }
    

    func displayNoSearchResults() {
        self.noResultsLabel.isHidden = false
        self.noResultsImageView.isHidden = false
    }
    

    func hideNoSearchResults() {
        self.noResultsLabel.isHidden = true
        self.noResultsImageView.isHidden = true
    }
    

    func displayLoadingAnimation() {
        DispatchQueue.main.async {
            self.loadingView.isHidden = false
            self.loadingView.loadIndicator.startAnimating()
        }
    }
    

    func removeLoadingAnimation() {
        DispatchQueue.main.async {
            self.loadingView.isHidden = true
            self.loadingView.loadIndicator.stopAnimating()
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.popViewController(animated: false)
    }
}


// MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.text != nil && textField.text != "" {
            var cleanSearchWords = textField.text!.lowercased()
            let removeCharacters: Set<Character> = [".", "\"", ",", "?", "!", "@", "#", "$", "%", "^", "&", "*"]
            cleanSearchWords.removeAll(where: { removeCharacters.contains($0) } )
            textField.text = cleanSearchWords
        }
        searchResultsTableView.isHidden = true
        recentSearchesView.isHidden = false
        recentSearchesTableView.isHidden = false
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if searchClearImageName == .search {
            searchClearIcon.image = UIImage(named: "remove")
            searchClearImageName = .remove
        }
    }
    
    
    @objc func searchClearButtonPressed(tapGestureRecognizer: UITapGestureRecognizer) {
        if searchClearImageName == .search {
            if searchTextField.text == "" {
                searchTextField.placeholder = "Enter search keywords"
            }
        } else {
            searchTextField.text = ""
            if searchClearImageName == .remove {
                searchClearIcon.image = UIImage(named: "search")
                searchClearImageName = .search
            }
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if searchTextField.text == "" {
            searchTextField.placeholder = "Enter search keywords"
            return false
        } else {
            return true
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let searchText = searchTextField.text {
            fetchInitialSearchResults(of: searchText)
        }
    }
}

// MARK: - RecentSearchCellDelegate
extension SearchViewController: RecentSearchCellDelegate {
    
    func recentSearchPressed(called searchName: String) {
        searchTextField.text = searchName
        searchTextField.endEditing(true)
        if searchClearImageName == .search {
            searchClearIcon.image = UIImage(named: "remove")
            searchClearImageName = .remove
        }
        fetchInitialSearchResults(of: searchName)
        if isSaveSearches {
            viewModel.updateRecentSearchesHistoryOrder(selectedSearch: searchName) {
                DispatchQueue.main.async {
                    self.recentSearchesDataSource.models = self.viewModel.recentSearchesArray
                    self.recentSearchesTableView.reloadData()
                }
            }
        }
    }
    
    
    func removeCellButtonDidPress(called searchName: String) {
        if isSaveSearches {
            viewModel.removeItemFromRecentSearchesHistory(searchToRemove: searchName) {
                //self.recentSearchesDataSource.models = self.viewModel.recentSearchesArray
                DispatchQueue.main.async {
                    self.recentSearchesTableView.reloadData()
                }
            }
        }
    }
}

// MARK: - NewsCellDelegate
extension SearchViewController: NewsCellDelegate {
    
    func actionButtonDidPress(inside article: Article) {
        selectedArticle = article
        self.performSegue(withIdentifier: Constants.Segues.SEARCH_TO_ARTICLE, sender: self)
    }
    
    override func prepare( for segue: UIStoryboardSegue, sender: Any? ) {
        if let selectedArticle = selectedArticle {
            if segue.identifier == Constants.Segues.SEARCH_TO_ARTICLE {
                let destinationVC = segue.destination as! ArticleViewController
                destinationVC.currentArticle = selectedArticle
            }
        }
    }
    
    
    func favoriteIconDidPress(forArticle article: Article) {
        if article.isFavorite {
            viewModel.removeArticleFromFavorites(articleID: article.id) { error, index in
                if let error = error {
                    print("Couldn't add to favorites - \(error)")
                } else {
                    DispatchQueue.main.async {
                        if let index = index {
                            let indexPath = IndexPath(row: index, section: 0)
                            self.recentSearchesTableView.beginUpdates()
                            self.searchResultsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                            self.recentSearchesTableView.endUpdates()
                        } else {
                            self.searchResultsTableView.reloadData()
                        }
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenter.HOMEPAGE_TO_FAVORITES), object: nil)
                }
            }
        } else {
            viewModel.addArticleToFavorites(article) { error, index in
                if let error = error {
                    print("Couldn't add to favorites - \(error)")
                } else {
                    DispatchQueue.main.async {
                        if let index = index {
                            let indexPath = IndexPath(row: index, section: 0)
                            self.searchResultsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                        } else {
                            self.searchResultsTableView.reloadData()
                        }
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenter.HOMEPAGE_TO_FAVORITES), object: nil)
                }
            }
        }
    }
}

// MARK: - SortbyViewDelegate
extension SearchViewController: SortbyViewDelegate {
    
    func filterIconDidPress() {
        print("Filter Icon Pressed")
    }
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == searchResultsTableView {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension SearchViewController: UIScrollViewDelegate {
    
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
        if position > (searchResultsTableView.contentSize.height - 100 - scrollView.frame.size.height) && !isPaginating {
            isPaginating = true
            viewModel.fetchNewsFromAPI(searchWords: searchTextField.text!, pageSizeToFetch: .articlesList) { error, numArticlesFetched in
                if error == nil {
                    DispatchQueue.main.async {
                        if numArticlesFetched != 0 {
                            self.searchResultsTableView.beginUpdates()
                            var indexPaths = [IndexPath]()
                            let originalLastIndex = self.viewModel.newsArray.count - 1 - numArticlesFetched!
                            let newLastIndex = self.viewModel.newsArray.count - 1
                            for i in originalLastIndex...(newLastIndex - 1) {
                                indexPaths.append(IndexPath(row: i + 1, section: 0))
                            }
                            self.searchResultsTableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                            self.searchResultsTableView.endUpdates()
                        }
                        self.searchResultsTableView.tableFooterView = nil
                    }
                } else {
                    print(error!)
                }
                self.isPaginating = false
            }
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    
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
        currentCell.titleLabel.text = viewModel.newsArray[indexPath.row].articleTitle
        currentCell.authorLabel.text = viewModel.newsArray[indexPath.row].author
        
        currentCell.articleUrl = viewModel.newsArray[indexPath.row].url
        currentCell.articleImageUrl = viewModel.newsArray[indexPath.row].imageUrl ?? ""
        currentCell.subjectTag.setTitle(viewModel.newsArray[indexPath.row].topic, for: .normal)
        currentCell.summaryLabel.text = viewModel.newsArray[indexPath.row].content
        if let date = adaptDateTimeFormat(currentFormat: "yyyy-MM-dd HH:mm:ss", desiredFormat: "EEEE MMM d, yyyy", timestampToAdapt: viewModel.newsArray[indexPath.row].date) {
            currentCell.dateLabel.text = date
        } else {
            currentCell.dateLabel.text = viewModel.newsArray[indexPath.row].date
        }
        
        if let imageUrl = viewModel.newsArray[indexPath.row].imageUrl {
            currentCell.articleImageUrl = imageUrl
            currentCell.newsImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "light-gray-background"))
        } else {
            currentCell.newsImage.image = UIImage(named: "light-gray-background")
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

import UIKit

class NotificationsViewController: UIViewController {

    @IBOutlet weak var customHeader: CustomHeaderView!
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = NotificationsViewModel()
    var dataSource: TableViewDataSourceManager<NotificationModel>!
    var selectedArticle: Article?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defineNotificationCenterListeners()
        initiateUIElements()
        getUserNotifications()
    }
    
    func defineNotificationCenterListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.getUserNotifications), name: NSNotification.Name(rawValue: Constants.NotificationCenter.NOTIFICATION_RECIVED), object: nil)
    }
    
    @objc func getUserNotifications() {
        viewModel.fetchNotificationsFromFirestore() {
            DispatchQueue.main.async {
                self.dataSource.models = self.viewModel.notificationsArray
                self.tableView.reloadData()
            }
        }
    }
    
    func initiateUIElements() {
        customHeader.initView(delegate: self, apperanceType: .backOnlyAppearance)
        setupTableView()
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: Constants.NibNames.NOTIFICATION, bundle: nil), forCellReuseIdentifier: Constants.TableCellsIdentifier.NOTIFICATION)
        self.dataSource = TableViewDataSourceManager(
            models: viewModel.notificationsArray,
            reuseIdentifier: Constants.TableCellsIdentifier.NOTIFICATION
        ) { notification, cell in
            let currentCell = cell as! NotificationCell
            currentCell.delegate = self
            currentCell.notificationID = notification.id
            currentCell.label.text = notification.text
            currentCell.notificationRead = notification.wasRead
            currentCell.notifcationDate = notification.date
            currentCell.notificationArticle = notification.article
            if notification.wasRead {
                currentCell.label.textColor = UIColor.lightGray
                currentCell.entireCell.backgroundColor = hexStringToUIColor(hex: "#FAFAFA")
                currentCell.verticalLine.image = UIImage(named: "NotificationVerticleLine-Gray")
            }
        }
        tableView.dataSource = dataSource
        tableView.delegate = self
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        setStatusBarColor(viewController: self, hexColor: "262146")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.popViewController(animated: false)
    }
}


//MARK: - CustomHeaderViewDelegate
extension NotificationsViewController: CustomHeaderViewDelegate {

    func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - UITableViewDelegate
extension NotificationsViewController: UITableViewDelegate {
    
    // TO DO: add pagination & loading footer to table
}


//MARK: - NotificationCellDelegate
extension NotificationsViewController: NotificationCellDelegate {
    
    func notificationDidPress(notification: NotificationModel) {
        
        if notification.id != "-1" {
            //Set notification as read
            viewModel.setNotificationAsRead(byID: notification.id) { error, stillUnreadNotificatons in
                if let error = error {
                    print(error)
                }
                DispatchQueue.main.async {
                    self.dataSource.models = self.viewModel.notificationsArray
                    self.tableView.reloadData()
                }
                if !stillUnreadNotificatons {
                    self.customHeader.displayNoNotification()
                }
            }
        } else {
            print("invalid notification")
        }
        
        //Move user to view clicked article
        if notification.article != nil {
            selectedArticle = notification.article
            self.performSegue(withIdentifier: Constants.Segues.NOTIFICATIONS_TO_ARTICLE, sender: self)
        }
    }
    
    
    // TO DO : make sure notifications contains all needed data for the article it should present !!!
    override func prepare( for segue: UIStoryboardSegue, sender: Any? ) {
        if let selectedArticle = selectedArticle {
            if segue.identifier == Constants.Segues.NOTIFICATIONS_TO_ARTICLE {
                let destinationVC = segue.destination as! ArticleViewController
                destinationVC.currentArticle = selectedArticle
            }
        }
    }
}

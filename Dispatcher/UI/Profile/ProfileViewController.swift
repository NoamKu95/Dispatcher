import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var userProfileShadowView: UIView!
    @IBOutlet weak var helloUserLabel: UILabel!
    @IBOutlet weak var editProfileLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = ProfileViewModel()
    var dataSource: TableViewDataSourceManager<ProfileOptionModel>!
    
    var userImage: UIImage? = nil
    var userName: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        getUserDetails()
        initiateUIElements()
        defineGestureRecognizers()
        defineNotificationCenterListeners()
    }
    
    func getUserDetails() {
        viewModel.fetchUserData() { userName, userImage in
            if let userName = userName {
                self.helloUserLabel.text = "Hi, \(userName)"
            }
            if let imgData = userImage as? NSData {
                self.userImage = UIImage(data: imgData as Data)
                self.userProfileImage.image = self.userImage
                
            }
        }
    }

    
    func initiateUIElements() {
        addShadowsToHeader()
        userProfileImage.layer.cornerRadius = userProfileImage.frame.width / 2
        userProfileImage.layer.masksToBounds = true
        setupTableView()
    }
    
    
    func defineGestureRecognizers() {
        editProfileLabel.addGestureRecognizer(UITapGestureRecognizer(target: editProfileLabel, action: #selector(editProfileButtonPressed)))
        editProfileLabel.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editProfileButtonPressed(tapGestureRecognizer:)))
        editProfileLabel.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    func defineNotificationCenterListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateDisplayOfUserDetails), name: NSNotification.Name(rawValue:  Constants.NotificationCenter.PICTURE_UPDATE ), object: nil)
    }
    
    
    @objc func updateDisplayOfUserDetails(_ notification: NSNotification) {
        if let userName = notification.userInfo!["userName"] as? String {
            helloUserLabel.text = "Hi, \(userName)"
        }
        if let userImage = notification.userInfo!["userImage"] as? UIImage {
            userProfileImage.image = userImage
            self.userImage = userImage
        }
    }
    
    
    func addShadowsToHeader() {
        userProfileShadowView.layer.masksToBounds = false
        userProfileShadowView.layer.shadowColor = UIColor.black.cgColor
        userProfileShadowView.layer.shadowOpacity = 0.2
        userProfileShadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        userProfileShadowView.layer.shadowRadius = 3
    }
    
    
    func setupTableView() {
        tableView.register(UINib(nibName: Constants.NibNames.PROFILE_OPTION, bundle: nil), forCellReuseIdentifier: Constants.TableCellsIdentifier.PROFILE_OPTION)
        self.dataSource = TableViewDataSourceManager(
            models: viewModel.optionsArray,
            reuseIdentifier: Constants.TableCellsIdentifier.PROFILE_OPTION
        ) { option, cell in
            let currentcell = cell as! ProfileOptionCell
            currentcell.label.text = option.text
            currentcell.iconImageView.image = UIImage(named: option.icon)
        }
        tableView.dataSource = dataSource
        tableView.delegate = self
    }
    
    
    @objc func editProfileButtonPressed(tapGestureRecognizer: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: Constants.Segues.GO_TO_UPDATE_PROFILE, sender: self)
    }
    
    
    override func prepare( for segue: UIStoryboardSegue, sender: Any? ) {
        if segue.identifier == Constants.Segues.GO_TO_UPDATE_PROFILE {
            let destinationVC = segue.destination as! ViewProfileViewController
            if let userImage = userImage {
                destinationVC.existingProfilePicture = userImage
            }
            if let userName = userName {
                destinationVC.userName = userName
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}


//MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if viewModel.optionsArray[indexPath.row].text.uppercased() != Constants.ButtonsText.LOGOUT {
            if viewModel.optionsArray[indexPath.row].navigateTo != nil {
                self.performSegue(withIdentifier: viewModel.optionsArray[indexPath.row].navigateTo!, sender: self)
            }
        } else {
            viewModel.logUserOut() { error in
                if let error = error {
                    print(error)
                } else {
                    let login = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "AuthViewController")
                    self.present(login, animated: true, completion: nil)
                }
            }
        }
    }
}

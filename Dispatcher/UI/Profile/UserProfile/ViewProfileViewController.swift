import UIKit
import FirebaseStorage

class ViewProfileViewController: UIViewController {

    @IBOutlet weak var customHeader: CustomHeaderView!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var screenTitle: UILabel!
    
    var storage = Storage.storage().reference()
    
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var changePictureLabel: UILabel!
    
    @IBOutlet weak var nameInputView: FormInputView!
    @IBOutlet weak var emailInputView: FormInputView!
    
    @IBOutlet weak var darkBackgroundView: UIView!
    @IBOutlet weak var popupView: ActionPopupView!
    
    
    var newProfilePicture: UIImage? = nil
    var newPictureURL: String? = nil
    var newName: String?
    var newEmail: String?
    
    var existingProfilePicture: UIImage? = nil
    var userName: String?
    var userEmail: String?
    
    
    let viewModel = ViewProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUserDetails()
        initializeUIElements()
    }
    
    
    func fetchUserDetails() {
        
        if userName == nil {
            viewModel.getDataOnUser(subject: Constants.UserDefaults.CURRENT_USER_NAME) { userName in
                if let userName = userName as? String {
                    self.userName = userName
                } else {
                    print("couldn't get user name from user details")
                }
            }
        }
        
        if existingProfilePicture == nil {
            viewModel.getDataOnUser(subject: Constants.UserDefaults.CURRENT_USER_IMAGE) { image in
                if let image = image as? NSData {
                    self.userPicture.image = UIImage(data: image as Data)
                } else {
                    print("couldn't get user image from user details")
                }
            }
        } else {
            self.userPicture.image = existingProfilePicture
        }
        
        viewModel.getDataOnUser(subject: Constants.TextFieldsIDs.USRE_EMAIL) { email in
            if let email = email as? NSData {
                let emailAsString : String = NSString(data: email as Data, encoding: String.Encoding.utf8.rawValue)! as String
                self.userEmail = emailAsString
            } else {
                print("couldn't get user email from keychain")
            }
        }
    }
    

    func initializeUIElements() {
        customHeader.initView(delegate: self, apperanceType: .backOnlyAppearance)
        popupView.initView(delegate: self)
        initTextInputs()
        userPicture.layer.cornerRadius = userPicture.frame.width / 2
        userPicture.layer.masksToBounds = true
        stopEditingProfileUI()
        hideAlert()
    }

    func initTextInputs() {
        nameInputView.initView(id: Constants.TextFieldsIDs.NAME, delegate: self, labelText: "Invalid name", placeholderText: "")
        emailInputView.initView(id: Constants.TextFieldsIDs.USRE_EMAIL, delegate: self, labelText: "Invalid email", placeholderText: "")
        nameInputView.textField.text = userName
        emailInputView.textField.text = userEmail
        nameInputView.contentView.backgroundColor = .white
        emailInputView.contentView.backgroundColor = .white
    }

    
    @IBAction func editProfileButtonPressed(_ sender: Any) {
        customHeader.updateHeaderAppearanceType(to: .confirmCancelAppearance)
        startEditingProfileUI()
        nameInputView.displayEditMode()
        emailInputView.displayEditMode()
        defineGestureRecognizers()
    }
    

    func defineGestureRecognizers() {
        changePictureLabel.addGestureRecognizer(UITapGestureRecognizer(target: changePictureLabel, action: #selector(changePicturePressed)))
        changePictureLabel.isUserInteractionEnabled = true
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(changePicturePressed(tapGestureRecognizer:)))
        changePictureLabel.addGestureRecognizer(tapGestureRecognizer1)
        
        darkBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: darkBackgroundView, action: #selector(dismissPopup)))
        darkBackgroundView.isUserInteractionEnabled = true
               let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(dismissPopup(tapGestureRecognizer:)))
        darkBackgroundView.addGestureRecognizer(tapGestureRecognizer2)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        emailInputView.textField.resignFirstResponder()
        nameInputView.textField.resignFirstResponder()
    }
    
    
    @objc func changePicturePressed(tapGestureRecognizer: UITapGestureRecognizer) {
        popupView.reArrangePopupView(toState: .selectPictureFrom)
        displayAlert()
    }
    

    func displayImagePicker(sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        return imagePicker
    }
   

    func displayAlert() {
        darkBackgroundView.isHidden = false
        popupView.isHidden = false
    }
    
    func hideAlert() {
        darkBackgroundView.isHidden = true
        popupView.isHidden = true
    }

    func startEditingProfileUI() {
        screenTitle.isHidden = true
        editProfileButton.isHidden = true
        changePictureLabel.isHidden = false
        nameInputView.textField.isEnabled = true
        emailInputView.textField.isEnabled = true
    }
    
    func stopEditingProfileUI() {
        screenTitle.isHidden = false
        editProfileButton.isHidden = false
        changePictureLabel.isHidden = true
        nameInputView.textField.isEnabled = false
        emailInputView.textField.isEnabled = false
        nameInputView.dismissEditMode()
        emailInputView.dismissEditMode()
    }

    
    @objc func dismissPopup(tapGestureRecognizer: UITapGestureRecognizer) {
        hideAlert()
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
extension ViewProfileViewController: CustomHeaderViewDelegate {
    
    func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    

    func checkmarkButtonPressed() {

        if newName != nil || newEmail != nil || newProfilePicture != nil {
            var isFormCorrect = true
            
            if newName != nil && newName!.count < 3 {
                nameInputView.displayWarning()
                isFormCorrect = false
            }
            
            if newEmail != nil && newEmail!.count < 5 {
                emailInputView.displayWarning()
                isFormCorrect = false
            }
            
            
            if isFormCorrect {
                if newName != nil && newName != userName {
                    viewModel.updateUserDetail(detailType: Constants.UserDefaults.CURRENT_USER_NAME, data: newName!)
                    let dataDictionary : [String: String] = ["userName" : newName ?? userName!]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenter.PICTURE_UPDATE ), object: nil, userInfo: dataDictionary)
                }
                
                if newEmail != nil && newEmail != userEmail && viewModel.isValidEmailAddress(email: newEmail!) {
                    viewModel.updateUserDetail(detailType: Constants.TextFieldsIDs.USRE_EMAIL, data: newEmail!)
                }
                
                if let newProfilePicture = newProfilePicture {
                    
                    let dataDictionary : [String: UIImage] = ["userImage" : newProfilePicture]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenter.PICTURE_UPDATE), object: nil, userInfo: dataDictionary)
                    
                    uploadPictureToCloudStorage(image: newProfilePicture) { error, url in
                        if let error = error {
                            print("Error - \(error)")
                        } else {
                            self.viewModel.updateUserDetail(detailType: Constants.UserDefaults.CURRENT_USER_IMAGE, data: url!)
                            let data = newProfilePicture.pngData()
                            if let data = data {
                                self.viewModel.updateUserDetail(detailType: Constants.UserDefaults.CURRENT_USER_IMAGE, data: data)
                            }
                        }
                    }
                }
                
                popupView.reArrangePopupView(toState: .confirmAlert)
                stopEditingProfileUI()
                displayAlert()
            }
        } else {
            cancelButtonPressed()
        }
    }
    

    func cancelButtonPressed() {
        nameInputView.textField.text = userName
        emailInputView.textField.text = userEmail
        if let existingProfilePicture = existingProfilePicture {
            userPicture.image = existingProfilePicture
        }
        customHeader.updateHeaderAppearanceType(to: .backOnlyAppearance)
        stopEditingProfileUI()
    }
}

//MARK: - FormInputViewDelegate
extension ViewProfileViewController: FormInputViewDelegate {
    
    func textFieldDidChange(inputView: FormInputView, textFieldId: String, currentText: String?) {
        if currentText!.count > 0 {
            inputView.hideWarning()
        }
        if textFieldId == Constants.TextFieldsIDs.NAME {
            newName = currentText
        } else {
            newEmail = currentText
        }
    }
}

//MARK: - ActionPopupViewDelegate
extension ViewProfileViewController: ActionPopupViewDelegate {
    
    func cameraButtonPressed() {
        let cameraImagePicker = self.displayImagePicker(sourceType: .camera)
        cameraImagePicker.delegate = self
        self.present(cameraImagePicker, animated: true)
        hideAlert()
    }
    

    func galleryButtonPressed() {
        let libraryImagePicker = self.displayImagePicker(sourceType: .photoLibrary)
        libraryImagePicker.delegate = self
        self.present(libraryImagePicker, animated: true)
        hideAlert()
    }
    

    func okButtonPressed() {
        hideAlert()
        customHeader.updateHeaderAppearanceType(to: .backOnlyAppearance)
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ViewProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        userPicture.image = image
        newProfilePicture = image
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func uploadPictureToCloudStorage(image: UIImage, completionHandler: @escaping (String?,String?) -> ()) {
        
        guard let imageData = image.pngData() else {
            completionHandler("Failed getting pngData",nil)
            return
        }
        let uid = viewModel.getUserUID()
        if let uid = uid {
            storage.child("\(uid)/profileIcon.png").putData(imageData, metadata: nil, completion: { _, error in
                guard error == nil else {
                    completionHandler("Failed to uplaod image to storage",nil)
                    return
                }
                self.storage.child("\(uid)/profileIcon.png").downloadURL( completion: { url, error in
                    guard let url = url, error == nil else {
                        completionHandler("Couldn't get downloadURL",nil)
                        return
                    }
                    let urlString = url.absoluteString
                    completionHandler(nil, urlString)
                })
            })
        } else {
            completionHandler("Couldn't get usernt user's uid",nil)
        }
    }
}

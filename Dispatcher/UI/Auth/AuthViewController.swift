import UIKit

class ActionButtonTapGesture: UITapGestureRecognizer {
    var sender = String()
}



enum SignupLoginPageCurrentView {
    case signup
    case login
}

class AuthViewController: UIViewController, LoadingViewDelegate {

    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailFormView: FormInputView!
    @IBOutlet weak var passwordFormView: FormInputView!
    @IBOutlet weak var reenterPasswordFormView: FormInputView!
    @IBOutlet weak var separatorLine: UIView!
    
    @IBOutlet weak var topButton: UIView!
    @IBOutlet weak var topButtonLabel: UILabel!
    @IBOutlet weak var bottomButton: UIView!
    @IBOutlet weak var bottomButtonLabel: UILabel!
    
    
    let viewModel = AuthViewModel()
    var currentPageType: SignupLoginPageCurrentView = .login
    
    var separatorConstraintLogin: NSLayoutConstraint? = nil
    var separatorConstraintSignup: NSLayoutConstraint? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initiateUIElements()
        defineGestureRecognizers()
        defineConstraints()
        setStatusBarColor(viewController: self, hexColor: "262146")
    }
    

    func initiateUIElements() {
        
        emailFormView.initView(id: Constants.TextFieldsIDs.EMAIL, delegate: self, labelText: "Invalid email adress", placeholderText: "Your Email")
        passwordFormView.initView(id: Constants.TextFieldsIDs.PASSWORD, delegate: self, labelText: "Weak password", placeholderText: "Password", hideIcon: false)
        reenterPasswordFormView.initView(id: Constants.TextFieldsIDs.PASSWORD_AGAIN, delegate: self, labelText: "Input doesn't match previous password", placeholderText: "Re-Enter Password", hideIcon: false)
        loadingView.initView(delegate: self)
        loadingView.isHidden = true
        
        // round buttons corners 10px
        topButton.layer.cornerRadius = 10.0
        bottomButton.layer.cornerRadius = 10.0
        
        //resize the image based on screen height
        logoImageView.translatesAutoresizingMaskIntoConstraints = true
        logoImageView.frame.size.height = UIScreen.main.bounds.height * 0.28

        if currentPageType == .login {
            setLoginPageLook()
        } else {
            setSignupPageLook()
        }
    }
    
    
    func defineGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        let buttonPress1 = ActionButtonTapGesture(target: self, action: #selector(self.actionButtonPressed))
        buttonPress1.sender = "topButton"
        topButton.isUserInteractionEnabled = true
        topButton.addGestureRecognizer(buttonPress1)
        
        let buttonPress2 = ActionButtonTapGesture(target: self, action: #selector(self.actionButtonPressed))
        buttonPress2.sender = "bottomButton"
        bottomButton.isUserInteractionEnabled = true
        bottomButton.addGestureRecognizer(buttonPress2)
    }
    
    
    @objc func actionButtonPressed(sender : ActionButtonTapGesture) {
        if sender.sender == "topButton" {
            if currentPageType == .login {
                loginExistingUser()
            } else {
                signupNewUser()
            }
        } else {
            if currentPageType == .login {
                setSignupPageLook()
            } else {
                setLoginPageLook()
            }
        }
    }
    
    

    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        emailFormView.textField.resignFirstResponder()
        passwordFormView.textField.resignFirstResponder()
        reenterPasswordFormView.textField.resignFirstResponder()
    }



    func defineConstraints() {
        separatorConstraintSignup = separatorLine.topAnchor.constraint(equalTo: reenterPasswordFormView.bottomAnchor, constant: 26.0)
        separatorConstraintSignup?.isActive = true
        
        separatorConstraintLogin = separatorLine.topAnchor.constraint(equalTo: passwordFormView.bottomAnchor, constant: 26.0)
        separatorConstraintLogin?.isActive = false
    }


    func setSignupPageLook() {
        DispatchQueue.main.async {
            self.clearAllUIElements()
            self.currentPageType = .signup
            self.titleLabel.text = "Signup"
            self.reenterPasswordFormView.isHidden = false
            self.separatorConstraintLogin?.isActive = false
            self.separatorConstraintSignup?.isActive = true
            
            self.topButtonLabel.text = Constants.ButtonsText.SIGNUP
            self.bottomButtonLabel.text = Constants.ButtonsText.LOGIN
        }
    }
    func setLoginPageLook() {
        DispatchQueue.main.async {
            self.clearAllUIElements()
            self.currentPageType = .login
            self.titleLabel.text = "Login"
            self.reenterPasswordFormView.isHidden = true
            self.separatorConstraintSignup?.isActive = false
            self.separatorConstraintLogin?.isActive = true
            
            self.topButtonLabel.text = Constants.ButtonsText.LOGIN
            self.bottomButtonLabel.text = Constants.ButtonsText.SIGNUP
        }
    }
    
    
    func clearAllUIElements() {
        emailFormView.resetElements()
        passwordFormView.resetElements()
        reenterPasswordFormView.resetElements()
    }
    

    func signupNewUser() {
        startLoadingAnimation()
        let currentPassword = passwordFormView.textField.text, passwordReenter = passwordFormView.textField.text
        if currentPassword != passwordReenter {
            reenterPasswordFormView.displayWarning()
            stopLoadingAnimation()
        } else {
            let currentEmail = emailFormView.textField.text
            viewModel.validateSignUpFields(email: currentEmail, password: currentPassword, passwordAgain: passwordReenter) { error, status in
                if !status {
                    print("Issue with text fields inputs - \(error!)")
                    self.stopLoadingAnimation()
                } else {
                    self.viewModel.signUserToApp(email: currentEmail!, password: currentPassword!) { error in
                        if let error = error {
                            print("Couldn't signup - \(error)")
                            self.stopLoadingAnimation()
                        } else {
                            self.clearAllUIElements()
                            self.stopLoadingAnimation()
                            self.navigateIntoApp()
                        }
                    }
                }
            }
        }
    }
    
    
    func loginExistingUser() {
        startLoadingAnimation()
        let email = emailFormView.textField.text, password = passwordFormView.textField.text
        var legitEmail = true, legitPassword = true
        
        if !viewModel.isValidEmailAddress(email: email ?? "") {
            emailFormView.displayWarning()
            legitEmail = false
        }
        if password == nil {
            passwordFormView.displayWarning()
            legitPassword = false
        }

        if legitEmail && legitPassword {
            viewModel.logUserToApp(email: email!, password: password!) { error in
                if let error = error {
                    print("Couldn't sign in - \(error)")
                } else {
                    self.clearAllUIElements()
                    self.navigateIntoApp()
                }
                self.stopLoadingAnimation()
            }
        } else {
            stopLoadingAnimation()
        }
    }
    
    
    func navigateIntoApp() {
        let homepage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyTabBarController")
        self.present(homepage, animated: true, completion: nil)
    }
    
    
    func startLoadingAnimation() {
        DispatchQueue.main.async {
            self.loadingView.isHidden = false
            self.loadingView.loadIndicator.startAnimating()
        }
    }
    
    
    func stopLoadingAnimation() {
        DispatchQueue.main.async {
            self.loadingView.loadIndicator.stopAnimating()
            self.loadingView.isHidden = true
        }
    }
}


// MARK: - FormInputViewDelegate
extension AuthViewController: FormInputViewDelegate {
    
    func textFieldDidChange(inputView: FormInputView, textFieldId: String, currentText: String?) {
        
        if currentPageType == .signup {
            if textFieldId == Constants.TextFieldsIDs.EMAIL {
                if currentText != nil && currentText!.count > 5 {
                    if !viewModel.isValidEmailAddress(email: currentText!) {
                        emailFormView.displayWarning()
                    } else {
                        emailFormView.hideWarning()
                    }
                }
                
            } else if textFieldId == Constants.TextFieldsIDs.PASSWORD {
                let isPasswordStrong = viewModel.isStrongPassword(password: currentText ?? "")
                if !isPasswordStrong {
                    passwordFormView.displayWarning()
                } else {
                    passwordFormView.hideWarning()
                }
                
            } else {
                if currentText != nil && currentText!.count > 5 {
                    if currentText != passwordFormView.textField.text {
                        reenterPasswordFormView.displayWarning()
                    } else {
                        reenterPasswordFormView.hideWarning()
                    }
                }
            }
        }
    }
}

// MARK: - MainActionButtonDelegate
extension AuthViewController: MainActionButtonDelegate {
    
    func actionButtonDidPress(btnText: String) {

        switch btnText {
        case Constants.ButtonsText.LOGIN:
            if currentPageType == .login {
                loginExistingUser()
            } else {
                setLoginPageLook()
            }
        case Constants.ButtonsText.SIGNUP:
            if currentPageType == .login {
                setSignupPageLook()
            } else {
                signupNewUser()
            }
        default:
            print("not optional")
        }
    }
}

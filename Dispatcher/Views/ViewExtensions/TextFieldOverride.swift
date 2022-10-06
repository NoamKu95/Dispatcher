import UIKit

extension UITextField {
    
    func paddingLeft(inset: CGFloat) {
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: inset, height: self.frame.height))
        self.leftViewMode = UITextField.ViewMode.always
    }
    
    func paddingRight(inset: CGFloat) {
        self.rightView = UIView(frame: CGRect(x: 0, y: 0, width: inset, height: self.frame.height))
        self.rightViewMode = UITextField.ViewMode.always
    }
    
    func horizontalPadding(leftInset: CGFloat, rightInset: CGFloat) {
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: leftInset, height: self.frame.height))
        self.leftViewMode = UITextField.ViewMode.always
        
        self.rightView = UIView(frame: CGRect(x: 0, y: 0, width: rightInset, height: self.frame.height))
        self.rightViewMode = UITextField.ViewMode.always
    }
    
    func disableAutoFill() {
        if #available(iOS 12, *) {
            textContentType = .oneTimeCode
        } else {
            textContentType = .init(rawValue: "")
        }
    }
}

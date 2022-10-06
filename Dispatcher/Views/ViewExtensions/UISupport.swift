
import UIKit

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

func adaptDateTimeFormat(currentFormat: String, desiredFormat: String, timestampToAdapt: String) -> String? {
    
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = currentFormat

    let dateFormatterPrint = DateFormatter()
    dateFormatterPrint.dateFormat = desiredFormat
    
    if let date = dateFormatterGet.date(from: timestampToAdapt) {
        return dateFormatterPrint.string(from: date)
    } else {
        return nil
    }
}


func setStatusBarColor(viewController: UIViewController, hexColor: String) {
    if #available(iOS 13.0, *) {
        let app = UIApplication.shared
        let statusBarHeight: CGFloat = app.statusBarFrame.size.height
        
        let statusbarView = UIView()
        statusbarView.backgroundColor = hexStringToUIColor(hex: "#\(hexColor)")
        viewController.view.addSubview(statusbarView)
      
        statusbarView.translatesAutoresizingMaskIntoConstraints = false
        statusbarView.heightAnchor
            .constraint(equalToConstant: statusBarHeight).isActive = true
        statusbarView.widthAnchor
            .constraint(equalTo: viewController.view.widthAnchor, multiplier: 1.0).isActive = true
        statusbarView.topAnchor
            .constraint(equalTo: viewController.view.topAnchor).isActive = true
        statusbarView.centerXAnchor
            .constraint(equalTo: viewController.view.centerXAnchor).isActive = true
      
    } else {
        let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
        statusBar?.backgroundColor = UIColor.red
    }
}


// MARK: - UIImage Extension to use URL
extension UIImage {

    public static func loadFrom(url: URL, completion: @escaping (_ image: UIImage?) -> ()) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    completion(UIImage(data: data))
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}

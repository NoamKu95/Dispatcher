import UIKit

class MyTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabIcons()
    }
    
    func setupTabIcons() {
        let iconTabProfile = self.tabBar.items![0] as UITabBarItem
        iconTabProfile.selectedImage = UIImage(named: "Profile-Selected")
        
        let iconTabHomepage = self.tabBar.items![1] as UITabBarItem
        iconTabHomepage.selectedImage = UIImage(named: "Homepage-Selected")
        
        let iconTabFavorites = self.tabBar.items![2] as UITabBarItem
        iconTabFavorites.selectedImage = UIImage(named: "Favorites-Selected")
    }
}

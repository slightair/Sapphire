import UIKit

struct MainTabBarControllerControllerBuilder {
    static func build() -> UIViewController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: MarketSummariesViewBuilder.build()),
            UINavigationController(rootViewController: BalancesViewBuilder.build()),
            UINavigationController(rootViewController: AssetsViewBuilder.build()),
        ]
        return tabBarController
    }
}

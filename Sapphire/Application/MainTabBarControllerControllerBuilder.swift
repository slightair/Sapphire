import UIKit

struct MainTabBarControllerControllerBuilder {
    static func build() -> UIViewController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            MarketSummariesSplitViewControllerBuilder.build(),
            UINavigationController(rootViewController: BalancesViewBuilder.build()),
            UINavigationController(rootViewController: OrdersViewBuilder.build()),
            UINavigationController(rootViewController: AssetsViewBuilder.build()),
        ]
        return tabBarController
    }
}

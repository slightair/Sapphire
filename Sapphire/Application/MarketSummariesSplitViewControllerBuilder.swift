import UIKit
import FontAwesome_swift

struct MarketSummariesSplitViewControllerBuilder {
    final class MarketSummariesSplitViewController: UISplitViewController {
        init() {
            super.init(nibName: nil, bundle: nil)

            tabBarItem.image = UIImage.fontAwesomeIcon(name: .lineChart, textColor: .white, size: CGSize(width: 32, height: 32))
            tabBarItem.title = "Market"
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    static func build() -> UIViewController {
        let masterViewController = UINavigationController(rootViewController: MarketSummariesViewBuilder.build())

        let splitViewController = MarketSummariesSplitViewController()
        splitViewController.viewControllers = [masterViewController]

        return splitViewController
    }
}

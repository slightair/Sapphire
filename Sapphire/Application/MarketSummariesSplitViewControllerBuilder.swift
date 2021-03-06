import UIKit
import FontAwesome

struct MarketSummariesSplitViewControllerBuilder {
    final class MarketSummariesSplitViewController: UISplitViewController {
        init() {
            super.init(nibName: nil, bundle: nil)

            tabBarItem.image = UIImage.fontAwesomeIcon(name: .chartLine, style: .solid, textColor: .white, size: CGSize(width: 32, height: 32))
            tabBarItem.title = "Market"
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    static func build() -> UIViewController {
        let dummyViewController = UIViewController()
        dummyViewController.title = "No market selected"
        dummyViewController.view.backgroundColor = .systemBackground

        let masterViewController = UINavigationController(rootViewController: MarketSummariesViewBuilder.build())
        let detailViewController = UINavigationController(rootViewController: dummyViewController)

        let splitViewController = MarketSummariesSplitViewController()
        splitViewController.viewControllers = [masterViewController, detailViewController]

        return splitViewController
    }
}

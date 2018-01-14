import UIKit
import XCGLogger

struct MainTabBarControllerControllerBuilder {
    static func build() -> UIViewController {
        guard let fileDestination = logger.destination(withIdentifier: XCGLogger.Constants.fileDestinationIdentifier) as? FileDestination else {
            fatalError("fileDestination not found")
        }
        let logDataSource = XCGLoggerFileLogDataSource(fileURL: fileDestination.writeToFileURL!)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            MarketSummariesSplitViewControllerBuilder.build(),
            UINavigationController(rootViewController: BalancesViewBuilder.build()),
            UINavigationController(rootViewController: OrdersViewBuilder.build()),
            UINavigationController(rootViewController: AssetsViewBuilder.build()),
            UINavigationController(rootViewController: LogViewerViewController(logDataSource: logDataSource)),
        ]
        return tabBarController
    }
}

import UIKit

final class OrdersWireframe: OrdersWireframeProtocol {
    private weak var viewController: OrdersViewController!

    init(viewController: OrdersViewController) {
        self.viewController = viewController
    }

    func presentMarketDetailView(market: String) {
        let marketDetailViewController = MarketDetailViewBuilder.build(market: market)
        viewController.navigationController?.pushViewController(marketDetailViewController, animated: true)
    }
}

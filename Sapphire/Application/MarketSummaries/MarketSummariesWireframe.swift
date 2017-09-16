import UIKit

final class MarketSummariesWireframe: MarketSummariesWireframeProtocol {
    private weak var viewController: MarketSummariesViewController!

    init(viewController: MarketSummariesViewController) {
        self.viewController = viewController
    }

    func presentMarketDetailView(market: String) {
        let marketDetailViewController = MarketDetailViewBuilder.build(market: market)
        let navigationController = UINavigationController(rootViewController: marketDetailViewController)
        viewController.showDetailViewController(navigationController, sender: self)
    }
}

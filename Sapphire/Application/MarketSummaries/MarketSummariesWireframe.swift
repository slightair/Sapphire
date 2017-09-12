import UIKit

final class MarketSummariesWireframe: MarketSummariesWireframeProtocol {
    private weak var viewController: MarketSummariesViewController!

    init(viewController: MarketSummariesViewController) {
        self.viewController = viewController
    }
}

import UIKit

final class MarketDetailWireframe: MarketDetailWireframeProtocol {
    private weak var viewController: MarketDetailViewController!

    init(viewController: MarketDetailViewController) {
        self.viewController = viewController
    }
}

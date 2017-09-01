import UIKit

final class BalancesWireframe: BalancesWireframeProtocol {
    private weak var viewController: BalancesViewController!

    init(viewController: BalancesViewController) {
        self.viewController = viewController
    }
}

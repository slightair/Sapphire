import UIKit

final class OrdersWireframe: OrdersWireframeProtocol {
    private weak var viewController: OrdersViewController!

    init(viewController: OrdersViewController) {
        self.viewController = viewController
    }
}

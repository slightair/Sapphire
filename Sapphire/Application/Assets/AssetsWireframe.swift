import UIKit

final class AssetsWireframe: AssetsWireframeProtocol {
    private weak var viewController: AssetsViewController!

    init(viewController: AssetsViewController) {
        self.viewController = viewController
    }
}

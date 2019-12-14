import UIKit

final class AssetsWireframe: AssetsWireframeProtocol {
    private weak var viewController: UIViewController!

    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}

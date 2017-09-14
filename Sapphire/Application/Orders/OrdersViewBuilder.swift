import UIKit

struct OrdersViewBuilder {
    static func build() -> UIViewController {
        let viewController = OrdersViewController()
        let interactor = OrdersInteractor(
            ordersUseCase: OrdersUseCase(
                bittrexRepository: BittrexRepository(dataStore: BittrexDataStore.shared)
            )
        )
        let wireframe = OrdersWireframe(viewController: viewController)
        let presenter = OrdersPresenter(view: viewController, interactor: interactor, wireframe: wireframe)

        viewController.inject(presenter: presenter)

        return viewController
    }
}

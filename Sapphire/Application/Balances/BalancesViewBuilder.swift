import UIKit

struct BalancesViewBuilder {
    static func build() -> UIViewController {
        let viewController = BalancesViewController()
        let interactor = BalancesInteractor(
            balancesUseCase: BalancesUseCase(
                bittrexRepository: BittrexRepository(dataStore: BittrexDataStore.shared),
                needsChart: true
            )
        )
        let wireframe = BalancesWireframe(viewController: viewController)
        let presenter = BalancesPresenter(view: viewController, interactor: interactor, wireframe: wireframe)

        viewController.inject(presenter: presenter)

        return viewController
    }
}

import UIKit

struct AssetsViewBuilder {
    static func build() -> UIViewController {
        let viewController = AssetsViewController()
        let interactor = AssetsInteractor(
            balancesUseCase: BalancesUseCase(
                bittrexRepository: BittrexRepository(dataStore: BittrexDataStore.shared),
                needsChart: false
            )
        )
        let wireframe = AssetsWireframe(viewController: viewController)
        let presenter = AssetsPresenter(view: viewController, interactor: interactor, wireframe: wireframe)

        viewController.inject(presenter: presenter)

        return viewController
    }
}

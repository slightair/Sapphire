import UIKit

struct MarketDetailViewBuilder {
    static func build(market: String) -> UIViewController {
        let viewController = MarketDetailViewController()
        let interactor = MarketDetailInteractor(
            market: market,
            marketDetailUseCase: MarketDetailUseCase(
                bittrexRepository: BittrexRepository(dataStore: BittrexDataStore.shared)
            )
        )
        let wireframe = MarketDetailWireframe(viewController: viewController)
        let presenter = MarketDetailPresenter(view: viewController, interactor: interactor, wireframe: wireframe)

        viewController.title = market
        viewController.inject(presenter: presenter)

        return viewController
    }
}

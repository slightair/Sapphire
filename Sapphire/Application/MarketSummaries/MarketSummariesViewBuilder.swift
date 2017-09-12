import UIKit

struct MarketSummariesViewBuilder {
    static func build() -> UIViewController {
        let viewController = MarketSummariesViewController()
        let interactor = MarketSummariesInteractor(
            marketSummariesUseCase: MarketSummariesUseCase(
                bittrexRepository: BittrexRepository(dataStore: BittrexDataStore.shared)
            )
        )
        let wireframe = MarketSummariesWireframe(viewController: viewController)
        let presenter = MarketSummariesPresenter(view: viewController, interactor: interactor, wireframe: wireframe)

        viewController.inject(presenter: presenter)

        return viewController
    }
}

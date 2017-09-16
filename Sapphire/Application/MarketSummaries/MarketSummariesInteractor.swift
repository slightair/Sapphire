import Foundation
import RxSwift

final class MarketSummariesInteractor: MarketSummariesInteractorProtocol {
    let marketSummariesUseCase: MarketSummariesUseCaseProtocol

    init(marketSummariesUseCase: MarketSummariesUseCaseProtocol) {
        self.marketSummariesUseCase = marketSummariesUseCase
    }

    func fetchMarketSummaryData() -> Single<[MarketSummaryData]> {
        return marketSummariesUseCase.fetchCurrentMarketSummaryData()
    }
}

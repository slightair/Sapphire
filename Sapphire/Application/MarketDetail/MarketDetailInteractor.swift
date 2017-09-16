import Foundation
import RxSwift

final class MarketDetailInteractor: MarketDetailInteractorProtocol {
    let market: String
    let marketDetailUseCase: MarketDetailUseCaseProtocol

    init(market: String, marketDetailUseCase: MarketDetailUseCaseProtocol) {
        self.market = market
        self.marketDetailUseCase = marketDetailUseCase
    }

    func fetchMarketDetailData(tickInterval: BittrexTickInterval) -> Single<MarketDetailData> {
        return marketDetailUseCase.fetchCurrentMarketDetailData(market: market, tickInterval: tickInterval)
    }
}

import Foundation
import RxSwift

protocol BittrexRepositoryProtocol {
    func fetchCurrentBalances() -> Single<[Balance]>
    func fetchCurrentMarketSummaries() -> Single<[MarketSummary]>
}

struct BittrexRepository: BittrexRepositoryProtocol {
    let dataStore: BittrexDataStoreProtocol

    func fetchCurrentBalances() -> Single<[Balance]> {
        return dataStore.fetchCurrentBalances()
    }

    func fetchCurrentMarketSummaries() -> Single<[MarketSummary]> {
        return dataStore.fetchCurrentMarketSummaries()
    }
}

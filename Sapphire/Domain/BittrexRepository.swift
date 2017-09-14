import Foundation
import RxSwift

protocol BittrexRepositoryProtocol {
    func fetchCurrentBalances() -> Single<[Balance]>
    func fetchCurrentMarketSummaries() -> Single<[MarketSummary]>
    func fetchCurrencies() -> Single<[Currency]>
    func fetchOrderHistory() -> Single<[Order]>
    func fetchOpenOrders() -> Single<[Order]>
}

struct BittrexRepository: BittrexRepositoryProtocol {
    let dataStore: BittrexDataStoreProtocol

    func fetchCurrentBalances() -> Single<[Balance]> {
        return dataStore.fetchCurrentBalances()
    }

    func fetchCurrentMarketSummaries() -> Single<[MarketSummary]> {
        return dataStore.fetchCurrentMarketSummaries()
    }

    func fetchCurrencies() -> Single<[Currency]> {
        return dataStore.fetchCurrencies()
    }

    func fetchOrderHistory() -> Single<[Order]> {
        return dataStore.fetchOrderHistory()
    }

    func fetchOpenOrders() -> Single<[Order]> {
        return dataStore.fetchOpenOrders()
    }
}

import Foundation
import RxSwift

enum BittrexTickInterval: String {
    case oneMin
    case fiveMin
    case thirtyMin
    case hour
    case day
}

protocol BittrexRepositoryProtocol {
    func fetchCurrentBalances() -> Single<[Balance]>
    func fetchCurrentMarketSummaries() -> Single<[MarketSummary]>
    func fetchCurrentMarketSummary(market: String) -> Single<MarketSummary>
    func fetchCurrencies() -> Single<[Currency]>
    func fetchOrderHistory() -> Single<[Order]>
    func fetchOrderHistory(market: String) -> Single<[Order]>
    func fetchOpenOrders() -> Single<[Order]>
    func fetchOpenOrders(market: String) -> Single<[Order]>
    func fetchCurrentChart(market: String, tickInterval: BittrexTickInterval) -> Single<Chart>
    func fetchMarkets() -> Single<[Market]>
}

struct BittrexRepository: BittrexRepositoryProtocol {
    let dataStore: BittrexDataStoreProtocol

    func fetchCurrentBalances() -> Single<[Balance]> {
        return dataStore.fetchCurrentBalances()
    }

    func fetchCurrentMarketSummaries() -> Single<[MarketSummary]> {
        return dataStore.fetchCurrentMarketSummaries()
    }

    func fetchCurrentMarketSummary(market: String) -> Single<MarketSummary> {
        return dataStore.fetchCurrentMarketSummary(market: market)
    }

    func fetchCurrencies() -> Single<[Currency]> {
        return dataStore.fetchCurrencies()
    }

    func fetchOrderHistory() -> Single<[Order]> {
        return dataStore.fetchOrderHistory()
    }

    func fetchOrderHistory(market: String) -> Single<[Order]> {
        return dataStore.fetchOrderHistory(market: market)
    }

    func fetchOpenOrders() -> Single<[Order]> {
        return dataStore.fetchOpenOrders()
    }

    func fetchOpenOrders(market: String) -> Single<[Order]> {
        return dataStore.fetchOpenOrders(market: market)
    }

    func fetchCurrentChart(market: String, tickInterval: BittrexTickInterval) -> Single<Chart> {
        return dataStore.fetchCurrentChart(market: market, tickInterval: tickInterval)
    }

    func fetchMarkets() -> Single<[Market]> {
        return dataStore.fetchMarkets()
    }
}

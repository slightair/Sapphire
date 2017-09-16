import Foundation
import RxSwift
import APIKit

protocol BittrexDataStoreProtocol {
    func fetchCurrentBalances() -> Single<[Balance]>
    func fetchCurrentMarketSummaries() -> Single<[MarketSummary]>
    func fetchCurrentMarketSummary(market: String) -> Single<MarketSummary>
    func fetchCurrencies() -> Single<[Currency]>
    func fetchOrderHistory() -> Single<[Order]>
    func fetchOrderHistory(market: String) -> Single<[Order]>
    func fetchOpenOrders() -> Single<[Order]>
    func fetchOpenOrders(market: String) -> Single<[Order]>
    func fetchCurrentChart(market: String, tickInterval: BittrexTickInterval) -> Single<Chart>
}

final class BittrexDataStore: BittrexDataStoreProtocol {
    static let shared = BittrexDataStore()

    let session = Session.shared
    var currencies: [Currency]?

    func fetchCurrentBalances() -> PrimitiveSequence<SingleTrait, [Balance]> {
        let request = BittrexAPI.CurrentBalancesRequest()
        return session.rx.response(request)
    }

    func fetchCurrentMarketSummaries() -> Single<[MarketSummary]> {
        let request = BittrexAPI.CurrentMarketSummariesRequest()
        return session.rx.response(request)
    }

    func fetchCurrentMarketSummary(market: String) -> Single<MarketSummary> {
        let request = BittrexAPI.CurrentMarketSummaryRequest(market: market)
        return session.rx.response(request)
            .flatMap { $0.first.flatMap { .just($0) } ?? .error(RxError.noElements) }
    }

    func fetchCurrencies() -> Single<[Currency]> {
        if let currencies = currencies {
            return .just(currencies)
        }

        let request = BittrexAPI.CurrenciesRequest()
        return session.rx.response(request)
            .do(onNext: { [weak self] currencies in
                self?.currencies = currencies
            })
    }

    func fetchOrderHistory() -> Single<[Order]> {
        let request = BittrexAPI.OrderHistoryRequest()
        return session.rx.response(request)
    }

    func fetchOrderHistory(market: String) -> Single<[Order]> {
        let request = BittrexAPI.OrderHistoryRequest(market: market)
        return session.rx.response(request)
    }

    func fetchOpenOrders() -> Single<[Order]> {
        let request = BittrexAPI.OpenOrdersRequest()
        return session.rx.response(request)
    }

    func fetchOpenOrders(market: String) -> Single<[Order]> {
        let request = BittrexAPI.OpenOrdersRequest(market: market)
        return session.rx.response(request)
    }

    func fetchCurrentChart(market: String, tickInterval: BittrexTickInterval) -> Single<Chart> {
        let request = BittrexAPI.CurrentTicksRequest(market: market, tickInterval: tickInterval)
        return session.rx.response(request)
            .map { Chart(market: market, tickInterval: tickInterval, ticks: $0) }
    }
}

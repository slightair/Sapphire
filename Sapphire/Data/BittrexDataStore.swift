import Foundation
import RxSwift
import APIKit

protocol BittrexDataStoreProtocol {
    func fetchCurrentBalances() -> Single<[Balance]>
    func fetchCurrentMarketSummaries() -> Single<[MarketSummary]>
    func fetchCurrencies() -> Single<[Currency]>
}

final class BittrexDataStore: BittrexDataStoreProtocol {
    static let shared = BittrexDataStore()

    let session = Session.verbose //shared
    var currencies: [Currency]?

    func fetchCurrentBalances() -> PrimitiveSequence<SingleTrait, [Balance]> {
        let request = BittrexAPI.CurrentBalancesRequest()
        return session.rx.response(request)
    }

    func fetchCurrentMarketSummaries() -> Single<[MarketSummary]> {
        let request = BittrexAPI.CurrentMarketSummariesRequest()
        return session.rx.response(request)
    }

    func fetchCurrencies() -> Single<[Currency]> {
        if let currencies = currencies {
            return .just(currencies)
        }

        let request = BittrexAPI.CurrenciesRequest()
        return session.rx.response(request).do(onNext: { [weak self] currencies in
            self?.currencies = currencies
        })
    }
}

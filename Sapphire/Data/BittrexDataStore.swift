import Foundation
import RxSwift
import APIKit

protocol BittrexDataStoreProtocol {
    func fetchCurrentBalances() -> Single<[Balance]>
    func fetchCurrentMarketSummaries() -> Single<[MarketSummary]>
}

struct BittrexDataStore: BittrexDataStoreProtocol {
    let session = Session.shared

    func fetchCurrentBalances() -> PrimitiveSequence<SingleTrait, [Balance]> {
        let request = BittrexAPI.CurrentBalancesRequest()
        return session.rx.response(request)
    }

    func fetchCurrentMarketSummaries() -> Single<[MarketSummary]> {
        let request = BittrexAPI.CurrentMarketSummariesRequest()
        return session.rx.response(request)
    }
}

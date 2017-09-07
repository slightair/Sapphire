import Foundation
import RxSwift
import APIKit

protocol BittrexDataStoreProtocol {
    func fetchCurrentBalances() -> Single<[Balance]>
}

struct BittrexDataStore: BittrexDataStoreProtocol {
    let session = Session.shared

    func fetchCurrentBalances() -> PrimitiveSequence<SingleTrait, [Balance]> {
        let request = BittrexAPI.CurrentBalancesRequest()
        return session.rx.response(request)
    }
}

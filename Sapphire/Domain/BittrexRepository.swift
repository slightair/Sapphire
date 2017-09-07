import Foundation
import RxSwift

protocol BittrexRepositoryProtocol {
    func fetchCurrentBalances() -> Single<[Balance]>
}

struct BittrexRepository: BittrexRepositoryProtocol {
    let dataStore: BittrexDataStoreProtocol

    func fetchCurrentBalances() -> Single<[Balance]> {
        return dataStore.fetchCurrentBalances()
    }
}

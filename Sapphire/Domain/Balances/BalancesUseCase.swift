import Foundation
import RxSwift

protocol BalancesUseCaseProtocol {
    func fetchCurrentBalanceData() -> Single<BalanceData>
}

struct BalancesUseCase: BalancesUseCaseProtocol {
    let bittrexRepository: BittrexRepositoryProtocol

    func fetchCurrentBalanceData() -> Single<BalanceData> {
        return bittrexRepository
            .fetchCurrentBalances()
            .map(BalancesUseCase.translate)
    }

    static func translate(balances: [Balance]) -> BalanceData {
        return BalanceData(date: Date(), items: balances.filter { $0.balance > 0 })
    }
}

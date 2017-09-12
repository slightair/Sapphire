import Foundation
import RxSwift

final class AssetsInteractor: AssetsInteractorProtocol {
    let balancesUseCase: BalancesUseCaseProtocol

    init(balancesUseCase: BalancesUseCaseProtocol) {
        self.balancesUseCase = balancesUseCase
    }

    func fetchBalanceData() -> Single<BalanceData> {
        return balancesUseCase.fetchCurrentBalanceData()
    }
}

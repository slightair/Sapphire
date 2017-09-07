import Foundation
import RxSwift
import RxCocoa

protocol BalancesViewProtocol: class {
    var refreshTrigger: Driver<Void> { get }
}

protocol BalancesPresenterProtocol: class {
    var balanceData: Driver<[BalanceData]> { get }
    var errors: Driver<Error> { get }
}

protocol BalancesInteractorProtocol: class {
    func fetchBalanceData() -> Single<BalanceData>
}

protocol BalancesWireframeProtocol: class {
}

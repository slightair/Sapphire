import Foundation
import RxSwift
import RxCocoa

protocol AssetsViewProtocol: class {
    var refreshTrigger: Driver<Void> { get }
}

protocol AssetsPresenterProtocol: class {
    var balanceData: Driver<BalanceData> { get }
    var errors: Driver<Error> { get }
}

protocol AssetsInteractorProtocol: class {
    func fetchBalanceData() -> Single<BalanceData>
}

protocol AssetsWireframeProtocol: class {
}

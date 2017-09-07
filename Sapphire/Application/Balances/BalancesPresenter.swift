import Foundation
import RxSwift
import RxCocoa

final class BalancesPresenter: BalancesPresenterProtocol {
    private weak var view: BalancesViewProtocol!
    private let interactor: BalancesInteractorProtocol
    private let wireframe: BalancesWireframeProtocol

    private(set) var balanceData: Driver<[BalanceData]> = .empty()

    private let errorSubject = PublishSubject<Error>()
    var errors: Driver<Error> {
        return errorSubject.asDriver(onErrorRecover: { _ in .never() })
    }

    init(view: BalancesViewProtocol, interactor: BalancesInteractorProtocol, wireframe: BalancesWireframeProtocol) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe

        balanceData = view.refreshTrigger.asObservable()
            .flatMapFirst { [weak self] _ -> Observable<BalanceData> in
                interactor.fetchBalanceData()
                    .asObservable()
                    .catchError { error in
                        self?.errorSubject.onNext(error)
                        return .empty()
                    }
            }
            .map { [$0] }
            .asDriver(onErrorJustReturn: [])
            .startWith([])
    }
}

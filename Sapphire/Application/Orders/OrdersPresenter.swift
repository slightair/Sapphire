import Foundation
import RxSwift
import RxCocoa

final class OrdersPresenter: OrdersPresenterProtocol {
    private weak var view: OrdersViewProtocol!
    private let interactor: OrdersInteractorProtocol
    private let wireframe: OrdersWireframeProtocol

    private(set) var orderData: Driver<[OrderData]> = .empty()

    private let errorSubject = PublishSubject<Error>()
    var errors: Driver<Error> {
        return errorSubject.asDriver(onErrorRecover: { _ in .never() })
    }

    let disposeBag = DisposeBag()

    init(view: OrdersViewProtocol, interactor: OrdersInteractorProtocol, wireframe: OrdersWireframeProtocol) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe

        orderData = view.refreshTrigger.asObservable()
            .flatMapFirst { [weak self] _ -> Observable<[OrderData]> in
                interactor.fetchOrderData()
                    .asObservable()
                    .catchError { error in
                        self?.errorSubject.onNext(error)
                        return .empty()
                    }
            }
            .asDriver(onErrorJustReturn: [])
            .startWith([])

        view.selectedMarket
            .drive(onNext: wireframe.presentMarketDetailView)
            .disposed(by: disposeBag)
    }
}

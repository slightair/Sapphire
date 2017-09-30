import Foundation
import RxSwift
import RxCocoa

final class MarketDetailPresenter: MarketDetailPresenterProtocol {
    private weak var view: MarketDetailViewProtocol!
    private let interactor: MarketDetailInteractorProtocol
    private let wireframe: MarketDetailWireframeProtocol

    private(set) var marketDetailData: Driver<MarketDetailData> = .empty()

    private let errorSubject = PublishSubject<Error>()
    var errors: Driver<Error> {
        return errorSubject.asDriver(onErrorRecover: { _ in .never() })
    }

    init(view: MarketDetailViewProtocol, interactor: MarketDetailInteractorProtocol, wireframe: MarketDetailWireframeProtocol) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe

        marketDetailData = view.refreshTrigger.asObservable()
            .flatMapFirst { [weak self] _ -> Observable<MarketDetailData> in
                interactor.fetchMarketDetailData(tickInterval: .thirtyMin)
                    .asObservable()
                    .catchError { error in
                        self?.errorSubject.onNext(error)
                        return .empty()
                    }
            }
            .asDriver(onErrorJustReturn: .empty)
            .startWith(.empty)
    }
}

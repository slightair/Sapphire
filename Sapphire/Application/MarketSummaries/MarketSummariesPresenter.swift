import Foundation
import RxSwift
import RxCocoa

final class MarketSummariesPresenter: MarketSummariesPresenterProtocol {
    private weak var view: MarketSummariesViewProtocol!
    private let interactor: MarketSummariesInteractorProtocol
    private let wireframe: MarketSummariesWireframeProtocol

    private(set) var marketSummaryData: Driver<[MarketSummaryData]> = .empty()

    private let errorSubject = PublishSubject<Error>()
    var errors: Driver<Error> {
        return errorSubject.asDriver(onErrorRecover: { _ in .never() })
    }

    init(view: MarketSummariesViewProtocol, interactor: MarketSummariesInteractorProtocol, wireframe: MarketSummariesWireframeProtocol) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe

        marketSummaryData = view.refreshTrigger.asObservable()
            .flatMapFirst { [weak self] _ -> Observable<[MarketSummaryData]> in
                interactor.fetchMarketSummaryData()
                    .asObservable()
                    .catchError { error in
                        self?.errorSubject.onNext(error)
                        return .empty()
                }
            }
            .asDriver(onErrorJustReturn: [])
            .startWith([])
    }
}

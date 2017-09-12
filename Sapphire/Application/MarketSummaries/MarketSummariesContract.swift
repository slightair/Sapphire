import Foundation
import RxSwift
import RxCocoa

protocol MarketSummariesViewProtocol: class {
    var refreshTrigger: Driver<Void> { get }
}

protocol MarketSummariesPresenterProtocol: class {
    var marketSummaryData: Driver<[MarketSummaryData]> { get }
    var errors: Driver<Error> { get }
}

protocol MarketSummariesInteractorProtocol: class {
    func fetchMarketSummaryData() -> Single<[MarketSummaryData]>
}

protocol MarketSummariesWireframeProtocol: class {
}

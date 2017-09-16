import Foundation
import RxSwift
import RxCocoa

protocol MarketDetailViewProtocol: class {
    var refreshTrigger: Driver<Void> { get }
}

protocol MarketDetailPresenterProtocol: class {
    var marketDetailData: Driver<MarketDetailData> { get }
    var errors: Driver<Error> { get }
}

protocol MarketDetailInteractorProtocol: class {
    func fetchMarketDetailData(tickInterval: BittrexTickInterval) -> Single<MarketDetailData>
}

protocol MarketDetailWireframeProtocol: class {
}

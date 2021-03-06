import Foundation
import RxSwift
import RxCocoa

protocol OrdersViewProtocol: class {
    var refreshTrigger: Driver<Void> { get }
    var selectedMarket: Driver<String> { get }
}

protocol OrdersPresenterProtocol: class {
    var orderData: Driver<[OrderData]> { get }
    var errors: Driver<Error> { get }
}

protocol OrdersInteractorProtocol: class {
    func fetchOrderData() -> Single<[OrderData]>
}

protocol OrdersWireframeProtocol: class {
    func presentMarketDetailView(market: String)
}

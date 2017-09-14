import Foundation
import RxSwift

final class OrdersInteractor: OrdersInteractorProtocol {
    let ordersUseCase: OrdersUseCaseProtocol

    init(ordersUseCase: OrdersUseCaseProtocol) {
        self.ordersUseCase = ordersUseCase
    }

    func fetchOrderData() -> Single<[OrderData]> {
        return ordersUseCase.fetchOrderData()
    }
}

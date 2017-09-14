import Foundation
import RxSwift

protocol OrdersUseCaseProtocol {
    func fetchOrderData() -> Single<[OrderData]>
}

struct OrdersUseCase: OrdersUseCaseProtocol {
    let bittrexRepository: BittrexRepositoryProtocol

    func fetchOrderData() -> Single<[OrderData]> {
        return Single.zip(
            bittrexRepository.fetchOpenOrders(),
            bittrexRepository.fetchOrderHistory()
        ).map(OrdersUseCase.translate)
    }

    static func translate(openOrders: [Order], orderHistory: [Order]) -> [OrderData] {
        let date = Date()
        return [
            OrderData(date: date, group: "Open", items: openOrders),
            OrderData(date: date, group: "Completed", items: orderHistory),
        ]
    }
}

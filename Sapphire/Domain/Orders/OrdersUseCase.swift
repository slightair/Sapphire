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
            bittrexRepository.fetchOrderHistory(),
            bittrexRepository.fetchCurrentMarketSummaries()
        ).map(OrdersUseCase.translate)
    }

    static func translate(openOrders: [Order], orderHistory: [Order], marketSummaries: [MarketSummary]) -> [OrderData] {
        let date = Date()

        let openOrderItems: [OrderData.OrderInfo] = openOrders.map { order in
            let last: Double?
            if let marketSummary = marketSummaries.first(where: { $0.marketName == order.exchange }) {
                last = marketSummary.last
            } else {
                last = nil
            }

            return OrderData.OrderInfo(
                exchange: order.exchange,
                orderType: order.orderType,
                limit: order.limit,
                last: last,
                quantity: order.quantity,
                opened: order.opened,
                closed: order.closed)
        }
        let orderHistoryItems: [OrderData.OrderInfo] = openOrders.map {
            OrderData.OrderInfo(
                exchange: $0.exchange,
                orderType: $0.orderType,
                limit: $0.limit,
                last: nil,
                quantity: $0.quantity,
                opened: $0.opened,
                closed: $0.closed)
        }

        return [
            OrderData(date: date, group: "Open", items: openOrderItems),
            OrderData(date: date, group: "Completed", items: orderHistoryItems),
        ]
    }
}

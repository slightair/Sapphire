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
            bittrexRepository.fetchCurrentMarketSummaries(),
            bittrexRepository.fetchMarkets()
        ).map(OrdersUseCase.translate)
    }

    static func translate(openOrders: [Order], orderHistory: [Order], marketSummaries: [MarketSummary], markets: [Market]) -> [OrderData] {
        let date = Date()

        let openOrderItems: [OrderData.OrderInfo] = openOrders.map { order in
            let last: Double?
            if let marketSummary = marketSummaries.first(where: { $0.marketName == order.exchange }) {
                last = marketSummary.last
            } else {
                last = nil
            }

            let logoImageURL: URL?
            if let market = markets.first(where: { $0.name == order.exchange }) {
                logoImageURL = market.logoImageURL
            } else {
                logoImageURL = nil
            }

            return OrderData.OrderInfo(
                exchange: order.exchange,
                orderType: order.orderType,
                limit: order.limit,
                last: last,
                quantity: order.quantity,
                opened: order.opened,
                closed: order.closed,
                logoImageURL: logoImageURL)
        }
        let orderHistoryItems: [OrderData.OrderInfo] = orderHistory.map { order in
            let logoImageURL: URL?
            if let market = markets.first(where: { $0.name == order.exchange }) {
                logoImageURL = market.logoImageURL
            } else {
                logoImageURL = nil
            }

            return OrderData.OrderInfo(
                exchange: order.exchange,
                orderType: order.orderType,
                limit: order.limit,
                last: nil,
                quantity: order.quantity,
                opened: order.opened,
                closed: order.closed,
                logoImageURL: logoImageURL)
        }

        return [
            OrderData(date: date, group: "Open", items: openOrderItems),
            OrderData(date: date, group: "Completed", items: orderHistoryItems),
        ]
    }
}

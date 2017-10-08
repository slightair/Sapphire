import Foundation
import RxDataSources

struct OrderData {
    struct OrderInfo {
        let exchange: String
        let orderType: String
        let limit: Double
        let last: Double?
        let quantity: Double
        let opened: Date
        let closed: Date?
        let logoImageURL: URL?

        var baseCurrency: String {
            let currencyPair = exchange.components(separatedBy: "-")
            return currencyPair[0]
        }

        var currency: String {
            let currencyPair = exchange.components(separatedBy: "-")
            return currencyPair[1]
        }

        var price: Double {
            return limit * quantity * (orderType == "LIMIT_SELL" ? 1 : -1)
        }
    }

    var date: Date
    var group: String
    var items: [OrderInfo]
}

extension OrderData: SectionModelType {
    typealias Item = OrderInfo

    init(original: OrderData, items: [OrderInfo]) {
        self = original
        self.items = items
    }
}

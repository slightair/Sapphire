import Foundation

struct Order {
    let uuid: String
    let exchange: String
    let orderType: String
    let limit: Double
    let quantity: Double
    let opened: Date
    let closed: Date?

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

    enum CodingKeys: String, CodingKey {
        case uuid = "OrderUuid"
        case exchange = "Exchange"
        case orderType = "OrderType"
        case limit = "Limit"
        case quantity = "Quantity"
        case opened = "Opened"
        case timeStamp = "TimeStamp"
        case closed = "Closed"
    }
}

extension Order: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let opened = try container.decodeIfPresent(Date.self, forKey: .opened)
        let timeStamp = try container.decodeIfPresent(Date.self, forKey: .timeStamp)
        let closed = try container.decodeIfPresent(Date.self, forKey: .closed)

        self.init(uuid: try container.decode(String.self, forKey: .uuid),
                  exchange: try container.decode(String.self, forKey: .exchange),
                  orderType: try container.decode(String.self, forKey: .orderType),
                  limit: try container.decode(Double.self, forKey: .limit),
                  quantity: try container.decode(Double.self, forKey: .quantity),
                  opened: opened ?? timeStamp ?? .distantPast,
                  closed: closed)
    }
}

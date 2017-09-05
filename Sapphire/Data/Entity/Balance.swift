import Foundation

struct Balance {
    let currency: String
    let balance: Double
    let available: Double
    let pending: Double

    enum CodingKeys: String, CodingKey {
        case currency = "Currency"
        case balance = "Balance"
        case available = "Available"
        case pending = "Pending"
    }
}

extension Balance: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.init(currency: try container.decode(String.self, forKey: .currency),
                  balance: try container.decode(Double.self, forKey: .balance),
                  available: try container.decode(Double.self, forKey: .available),
                  pending: try container.decode(Double.self, forKey: .pending))
    }
}

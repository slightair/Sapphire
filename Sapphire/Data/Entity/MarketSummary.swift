import Foundation

struct MarketSummary {
    let marketName: String
    let high: Double
    let low: Double
    let baseVolume: Double
    let last: Double
    let bid: Double
    let ask: Double
    let prevDay: Double

    enum CodingKeys: String, CodingKey {
        case marketName = "MarketName"
        case high = "High"
        case low = "Low"
        case baseVolume = "BaseVolume"
        case last = "Last"
        case bid = "Bid"
        case ask = "Ask"
        case prevDay = "PrevDay"
    }
}

extension MarketSummary: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.init(marketName: try container.decode(String.self, forKey: .marketName),
                  high: (try? container.decode(Double.self, forKey: .high)) ?? 0,
                  low: (try? container.decode(Double.self, forKey: .low)) ?? 0,
                  baseVolume: (try? container.decode(Double.self, forKey: .baseVolume)) ?? 0,
                  last: (try? container.decode(Double.self, forKey: .last)) ?? 0,
                  bid: (try? container.decode(Double.self, forKey: .bid)) ?? 0,
                  ask: (try? container.decode(Double.self, forKey: .ask)) ?? 0,
                  prevDay: (try? container.decode(Double.self, forKey: .prevDay)) ?? 0)
    }
}

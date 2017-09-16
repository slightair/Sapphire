import Foundation

struct Chart {
    struct Tick {
        let open: Double
        let high: Double
        let low: Double
        let close: Double
        let volume: Double
        let date: Date
        let baseVolume: Double

        enum CodingKeys: String, CodingKey {
            case open = "O"
            case high = "H"
            case low = "L"
            case close = "C"
            case volume = "V"
            case date = "T"
            case baseVolume = "BV"
        }
    }

    let market: String
    let tickInterval: BittrexTickInterval
    let ticks: [Tick]
}

extension Chart.Tick: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.init(open: try container.decode(Double.self, forKey: .open),
                  high: try container.decode(Double.self, forKey: .high),
                  low: try container.decode(Double.self, forKey: .low),
                  close: try container.decode(Double.self, forKey: .close),
                  volume: try container.decode(Double.self, forKey: .volume),
                  date: try container.decode(Date.self, forKey: .date),
                  baseVolume: try container.decode(Double.self, forKey: .baseVolume))
    }
}

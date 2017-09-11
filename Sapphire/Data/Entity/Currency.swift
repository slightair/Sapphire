import Foundation

struct Currency {
    let currency: String
    let currencyLong: String
    let txFee: Double
    let coinType: String

    enum CodingKeys: String, CodingKey {
        case currency = "Currency"
        case currencyLong = "CurrencyLong"
        case txFee = "TxFee"
        case coinType = "CoinType"
    }
}

extension Currency: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.init(currency: try container.decode(String.self, forKey: .currency),
                  currencyLong: try container.decode(String.self, forKey: .currencyLong),
                  txFee: try container.decode(Double.self, forKey: .txFee),
                  coinType: try container.decode(String.self, forKey: .coinType))
    }
}

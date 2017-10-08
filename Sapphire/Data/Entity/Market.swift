import Foundation

struct Market {
    let marketCurrency: String
    let baseCurrency: String
    let name: String
    let logoImageURL: URL?

    enum CodingKeys: String, CodingKey {
        case marketCurrency = "MarketCurrency"
        case baseCurrency = "BaseCurrency"
        case name = "MarketName"
        case logoImageURL = "LogoUrl"
    }
}

extension Market: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.init(marketCurrency: try container.decode(String.self, forKey: .marketCurrency),
                  baseCurrency: try container.decode(String.self, forKey: .baseCurrency),
                  name: try container.decode(String.self, forKey: .name),
                  logoImageURL: try container.decodeIfPresent(URL.self, forKey: .logoImageURL))
    }
}

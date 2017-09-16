import Foundation
import APIKit

extension BittrexAPI {
    struct CurrentMarketSummaryRequest: BittrexAPIRequest {
        typealias Response = [MarketSummary]

        let market: String

        let apiType: BittrexAPI.APIType = .public
        let method: HTTPMethod = .get
        let path: String = "/v1.1/public/getmarketsummary"

        var queryParameters: [String : Any]? {
            return [
                "market": market
            ]
        }
    }
}

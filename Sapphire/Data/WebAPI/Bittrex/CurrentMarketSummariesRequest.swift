import Foundation
import APIKit

extension BittrexAPI {
    struct CurrentMarketSummariesRequest: BittrexAPIRequest {
        typealias Response = [MarketSummary]

        let apiType: BittrexAPI.APIType = .public
        let method: HTTPMethod = .get
        let path: String = "/v1.1/public/getmarketsummaries"
    }
}

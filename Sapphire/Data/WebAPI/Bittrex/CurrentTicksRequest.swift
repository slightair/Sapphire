import Foundation
import APIKit

extension BittrexAPI {
    struct CurrentTicksRequest: BittrexAPIRequest {
        typealias Response = [Chart.Tick]

        let market: String
        let tickInterval: BittrexTickInterval

        let apiType: BittrexAPI.APIType = .public
        let method: HTTPMethod = .get
        let path: String = "/v2.0/pub/market/getticks"

        var queryParameters: [String: Any]? {
            return [
                "marketName": market,
                "tickInterval": tickInterval.rawValue,
            ]
        }
    }
}

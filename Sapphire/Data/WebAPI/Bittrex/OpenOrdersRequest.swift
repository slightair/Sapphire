import Foundation
import APIKit

extension BittrexAPI {
    struct OpenOrdersRequest: BittrexAPIRequest {
        typealias Response = [Order]

        let market: String?
        let apiType: BittrexAPI.APIType = .private
        let method: HTTPMethod = .get
        let path: String = "/v1.1/market/getopenorders"

        init(market: String? = nil) {
            self.market = market
        }

        var queryParameters: [String: Any]? {
            var params = defaultQueryParameters
            if let market = market {
                params["market"] = market
            }
            return params
        }
    }
}

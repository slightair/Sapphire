import Foundation
import APIKit

extension BittrexAPI {
    struct OpenOrdersRequest: BittrexAPIRequest {
        typealias Response = [Order]

        let apiType: BittrexAPI.APIType = .private
        let method: HTTPMethod = .get
        let path: String = "/v1.1/market/getopenorders"
    }
}

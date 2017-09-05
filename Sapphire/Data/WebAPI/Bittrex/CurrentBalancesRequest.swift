import Foundation
import APIKit

extension BittrexAPI {
    struct CurrentBalancesRequest: BittrexAPIRequest {
        typealias Response = [Balance]

        let apiType: BittrexAPI.APIType = .private
        let method: HTTPMethod = .get
        let path: String = "/v1.1/account/getbalances"
    }
}

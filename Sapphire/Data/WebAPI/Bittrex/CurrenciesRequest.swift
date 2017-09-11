import Foundation
import APIKit

extension BittrexAPI {
    struct CurrenciesRequest: BittrexAPIRequest {
        typealias Response = [Currency]

        let apiType: BittrexAPI.APIType = .public
        let method: HTTPMethod = .get
        let path: String = "/v1.1/public/getcurrencies"
    }
}

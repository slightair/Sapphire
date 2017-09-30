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

        func response(from object: Any, urlResponse _: HTTPURLResponse) throws -> Response {
            guard let data = object as? Data else {
                throw ResponseError.unexpectedObject(object)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601noneMilliSec)

            return try decoder.decode(BittrexAPI.Response<Response>.self, from: data).result
        }
    }
}

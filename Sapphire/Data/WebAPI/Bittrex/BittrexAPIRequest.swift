import Foundation
import APIKit

final class BittrexAPI: WebAPI {
    enum APIType {
        case `public`
        case `private`
    }

    struct Response<ResultType: Decodable> {
        enum CodingKeys: String, CodingKey {
            case success
            case message
            case result
        }

        let success: Bool
        let message: String
        let result: ResultType
    }

    struct NonceProvider {
        static var shared = NonceProvider()

        var nonce: String = ""

        init() {
            update()
        }

        mutating func update() {
            nonce = "\(Int(Date().timeIntervalSince1970 * 1000 + 3939))"
        }
    }
}

extension BittrexAPI.Response: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.init(success: try container.decode(Bool.self, forKey: .success),
                  message: try container.decode(String.self, forKey: .message),
                  result: try container.decode(ResultType.self, forKey: .result))
    }
}

protocol BittrexAPIRequest: Request {
    var apiType: BittrexAPI.APIType { get }
}

extension BittrexAPIRequest {
    var baseURL: URL {
        return URL(string: "https://bittrex.com/api")!
    }

    var defaultQueryParameters: [String: Any] {
        if apiType == .private {
            return [
                "apikey": SecureConfiguration.Bittrex.accessKey,
                "nonce": BittrexAPI.NonceProvider.shared.nonce,
            ]
        }
        return [:]
    }

    var queryParameters: [String: Any]? {
        return defaultQueryParameters
    }

    var headerFields: [String: String] {
        var fields = [
            "User-Agent": WebAPI.userAgent,
        ]

        if apiType == .private {
            fields["apisign"] = signature()
            BittrexAPI.NonceProvider.shared.update()
        }

        return fields
    }

    private func signature() -> String {
        let url = path.isEmpty ? baseURL : baseURL.appendingPathComponent(path)
        var urlString = url.absoluteString

        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            urlString += "?" + URLEncodedSerialization.string(from: queryParameters)
        }

        return hmacSHA512Digest(base: urlString, key: SecureConfiguration.Bittrex.secretAccessKey)
    }

    private func hmacSHA512Digest(base: String, key: String) -> String {
        guard let cKey = key.cString(using: .utf8) else {
            fatalError("Cannot convert key to C String")
        }
        let cKeyLength = key.lengthOfBytes(using: .utf8)

        guard let cData = base.cString(using: .utf8) else {
            fatalError("Cannot convert data to C String")
        }
        let cDataLength = base.lengthOfBytes(using: .utf8)

        let digestLength = Int(CC_SHA512_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLength)
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA512), cKey, cKeyLength, cData, cDataLength, result)

        var hexString = ""
        for i in 0 ..< digestLength {
            hexString += String(format: "%02x", result[i])
        }

        result.deallocate(capacity: digestLength)

        return hexString
    }
}

extension BittrexAPIRequest where Response: Decodable {
    var dataParser: DataParser {
        return DecodableDataParser()
    }

    func response(from object: Any, urlResponse _: HTTPURLResponse) throws -> Response {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(BittrexAPI.Response<Response>.self, from: data).result
    }
}

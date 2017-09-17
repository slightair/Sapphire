import Foundation
import RxDataSources

struct BalanceData {
    struct CurrencyInfo {
        let name: String
        let longName: String
        let balance: Double
        let last: Double?
        let high: Double?
        let low: Double?
        let change: Double?
        let estimatedBTCValue: Double
    }

    var date: Date
    var usdtAssets: Double
    var btcAssets: Double
    var items: [CurrencyInfo]

    static let empty = BalanceData(date: .distantPast, usdtAssets: 0, btcAssets: 0, items: [])
}

extension BalanceData: SectionModelType {
    typealias Item = CurrencyInfo

    init(original: BalanceData, items: [CurrencyInfo]) {
        self = original
        self.items = items
    }
}

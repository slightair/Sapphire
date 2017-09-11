import Foundation
import RxDataSources

struct BalanceData {
    struct CurrencyInfo {
        let name: String
        let longName: String
        let balance: Double
        let estimatedBTCValue: Int64
    }

    var date: Date
    var items: [CurrencyInfo]
}

extension BalanceData: SectionModelType {
    typealias Item = CurrencyInfo

    init(original: BalanceData, items: [CurrencyInfo]) {
        self = original
        self.items = items
    }
}

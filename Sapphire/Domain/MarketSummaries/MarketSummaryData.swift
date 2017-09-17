import Foundation
import RxDataSources

struct MarketSummaryData {
    struct CurrencyInfo {
        let market: String
        let name: String
        let longName: String
        let last: Double
        let high: Double
        let low: Double
        let baseVolume: Double
        let change: Double
    }

    var date: Date
    var marketGroup: String
    var items: [CurrencyInfo]

    static let empty = MarketSummaryData(date: .distantPast, marketGroup: "", items: [])
}

extension MarketSummaryData: SectionModelType {
    typealias Item = CurrencyInfo

    init(original: MarketSummaryData, items: [CurrencyInfo]) {
        self = original
        self.items = items
    }
}

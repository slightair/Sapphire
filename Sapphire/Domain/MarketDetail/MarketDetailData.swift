import Foundation
import RxDataSources

struct MarketDetailData {
    enum Section {
        case chart(items: [SectionItem])
        case summary(items: [SectionItem])
        case openOrders(items: [SectionItem])
        case orderHistory(items: [SectionItem])

        var title: String? {
            switch self {
            case .chart:
                return nil
            case .summary:
                return "Summary"
            case .openOrders:
                return "Open Orders"
            case .orderHistory:
                return "OrderHistory"
            }
        }
    }

    enum SectionItem {
        case chartSectionItem(chart: Chart)
        case summarySectionItem(currencyInfo: MarketSummaryData.CurrencyInfo)
        case openOrdersSectionItem(order: Order)
        case orderHistorySectionItem(order: Order)
    }

    var date: Date
    var sections: [Section]

    static let empty = MarketDetailData(date: .distantPast, sections: [])
}

extension MarketDetailData.Section: SectionModelType {
    typealias Item = MarketDetailData.SectionItem

    var items: [Item] {
        switch self {
        case .chart(items: let items):
            return items
        case .summary(items: let items):
            return items
        case .openOrders(items: let items):
            return items
        case .orderHistory(items: let items):
            return items
        }
    }

    init(original: MarketDetailData.Section, items: [Item]) {
        switch original {
        case .chart:
            self = .chart(items: items)
        case .summary:
            self = .summary(items: items)
        case .openOrders:
            self = .openOrders(items: items)
        case .orderHistory:
            self = .orderHistory(items: items)
        }
    }
}

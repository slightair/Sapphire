import Foundation
import RxDataSources

struct BalanceData {
    var date: Date
    var items: [Balance]
}

extension BalanceData: SectionModelType {
    typealias Item = Balance

    init(original: BalanceData, items: [Balance]) {
        self = original
        self.items = items
    }
}

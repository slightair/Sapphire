import Foundation
import RxDataSources

struct OrderData {
    var date: Date
    var group: String
    var items: [Order]
}

extension OrderData: SectionModelType {
    typealias Item = Order

    init(original: OrderData, items: [Order]) {
        self = original
        self.items = items
    }
}

import Foundation

extension DateFormatter {
    static let defaultDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "yy/MM/dd HH:mm"

        return formatter
    }()
}

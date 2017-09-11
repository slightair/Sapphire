import Foundation

extension DateFormatter {
    static let `default`: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "yy/MM/dd HH:mm"

        return formatter
    }()
}

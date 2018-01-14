import Foundation

protocol LogStore {
    func putLog(_ log: Codable, date: Date, labels: [String])
}

extension LogStore {
    func putLog(_ log: Codable, date: Date = Date(), labels: [String] = []) {
        putLog(log, date: date, labels: labels)
    }
}

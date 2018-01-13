import Foundation

class XCGLoggerFileLogDataSource: FileLogDataSource {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    override func readLine(_ line: String) {
        guard let regexp = try? NSRegularExpression(pattern: "(\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}.\\d{3})\\s\\[(.+?)\\]\\s(.+)") else {
            fatalError("Regular expression pattern is invalid")
        }

        if let result = regexp.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
            let terms = (1 ..< result.numberOfRanges).map { String(line[Range(result.range(at: $0), in: line)!]) }

            if let currentLogDate = currentLogDate {
                logs.append(Log(date: currentLogDate, labels: currentLogLabels, body: currentLogBody))
            }

            currentLogDate = dateFormatter.date(from: terms[0])
            currentLogLabels = [terms[1]]
            currentLogBody = terms[2]
        } else {
            currentLogBody += "\n\(line)"
        }
    }

    override func didLoadLogFile() {
        if let currentLogDate = currentLogDate {
            logs.append(Log(date: currentLogDate, labels: currentLogLabels, body: currentLogBody))
        }
    }
}

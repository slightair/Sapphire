import Foundation
import XCGLogger

extension Tag {
    static let networking = Tag("networking")
}

private let logDirectoryPath: String? = {
    guard let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
        return nil
    }
    return documentDirectoryPath + "/logs"
}()

let logger: XCGLogger = {
    let logger = XCGLogger(identifier: "SapphireLogger", includeDefaultDestinations: false)

    let systemDestination = AppleSystemLogDestination(identifier: XCGLogger.Constants.systemLogDestinationIdentifier)
    systemDestination.showLogIdentifier = false
    systemDestination.showFunctionName = false
    systemDestination.showThreadName = false
    systemDestination.showLevel = true
    systemDestination.showFileName = false
    systemDestination.showLineNumber = false
    systemDestination.showDate = true
    logger.add(destination: systemDestination)

    makeLogFileDirectoryIfNeeded()
    if let fileDestination = makeFileDestionation() {
        logger.add(destination: fileDestination)
    }

    logger.outputLevel = .verbose

    return logger
}()

private func makeLogFileDirectoryIfNeeded() {
    guard let logDirectoryPath = logDirectoryPath else {
        return
    }

    let fileManager = FileManager.default
    var isDirectory: ObjCBool = false
    if !fileManager.fileExists(atPath: logDirectoryPath, isDirectory: &isDirectory) {
        do {
            try fileManager.createDirectory(atPath: logDirectoryPath, withIntermediateDirectories: true)
        } catch {
            fatalError("Could not create log directory")
        }
        isDirectory = ObjCBool(true)
    }

    if !isDirectory.boolValue {
        fatalError("Unexpected situation")
    }
}

private func makeFileDestionation() -> FileDestination? {
    guard let logDirectoryPath = logDirectoryPath else {
        return nil
    }

    let dateFormatter = DateFormatter()
    dateFormatter.locale = .current
    dateFormatter.dateFormat = "yyyyMMddHHmmss"

    let launchDateString = dateFormatter.string(from: Date())
    let logFilePath = logDirectoryPath + "/\(launchDateString).log"
    print(logFilePath)

    let fileDestination = FileDestination(writeToFile: logFilePath, identifier: XCGLogger.Constants.fileDestinationIdentifier)
    fileDestination.showLogIdentifier = false
    fileDestination.showFunctionName = false
    fileDestination.showThreadName = false
    fileDestination.showLevel = true
    fileDestination.showFileName = false
    fileDestination.showLineNumber = false
    fileDestination.showDate = true
    fileDestination.logQueue = XCGLogger.logQueue

    return fileDestination
}

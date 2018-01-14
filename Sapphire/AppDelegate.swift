import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Appearance.setUp()

        let path = NSTemporaryDirectory() + "hoge.log"
        print(path)
        let fileURL = URL(fileURLWithPath: path)

        let store = FileLogStore(fileURL: fileURL)
        store.putLog(["hoge": "fuga"], labels: ["aaa", "test"])
        store.putLog(123, labels: ["aaa", "test"])
        store.putLog("hello", labels: ["\"aaa", "[hoge][fuga],xxx"])

        return true
    }
}

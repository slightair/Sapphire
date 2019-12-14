import UIKit

final class Appearance {
    static func setUp() {
        UITabBar.appearance().tintColor = .systemIndigo

        UINavigationBar.appearance().tintColor = .systemIndigo
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.systemIndigo]

        UILabel.appearance().textColor = .label
        UIButton.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).backgroundColor = .clear
        UIButton.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).tintColor = .systemGray
        UITableView.appearance().sectionIndexColor = .systemGray
    }
}

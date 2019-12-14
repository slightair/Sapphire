import UIKit

final class Appearance {
    static func setUp() {
        UILabel.appearance().textColor = .systemGray
        UIButton.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).backgroundColor = .clear
        UIButton.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).tintColor = .systemGray
        UITableView.appearance().sectionIndexColor = .systemGray
    }
}

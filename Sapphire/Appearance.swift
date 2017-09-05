import UIKit
import ChameleonFramework

final class Appearance {
    static func setUp() {
        Chameleon.setGlobalThemeUsingPrimaryColor(.flatBlue, with: .contrast)

        UILabel.appearance().textColor = .flatGray
        UIButton.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).backgroundColor = .clear
        UIButton.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).tintColor = .flatBlue
    }
}
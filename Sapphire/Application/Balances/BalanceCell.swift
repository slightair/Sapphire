import UIKit
import ChameleonFramework

class BalanceCell: UITableViewCell {
    static let rowHeight: CGFloat = 60
    static let placeholderImage = UIImage.fontAwesomeIcon(name: .question, textColor: .flatBlue, size: CGSize(width: 64, height: 64))

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currencyBalanceLabel: UILabel!
    @IBOutlet weak var estimatedBTCValueLabel: UILabel!
    @IBOutlet weak var lastValueLabel: UILabel!
    @IBOutlet weak var highAndLowLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!

    func update(currencyInfo: BalanceData.CurrencyInfo) {
        thumbnailImageView.image = UIImage(named: currencyInfo.name) ?? BalanceCell.placeholderImage
        currencyNameLabel.text = currencyInfo.longName
        currencyBalanceLabel.text = NumberFormatter.currency.string(from: NSNumber(value: currencyInfo.balance))
        estimatedBTCValueLabel.text = NumberFormatter.decimal.string(from: NSNumber(value: currencyInfo.estimatedBTCValue))

        if let change = currencyInfo.change {
            changeLabel.text = NumberFormatter.percent.string(from: NSNumber(value: change))
            changeLabel.textColor = change >= 0 ? .flatGreen : .flatRed
        } else {
            changeLabel.text = ""
            changeLabel.textColor = .flatBlue
        }

        if let last = currencyInfo.last {
            let lastString = NumberFormatter.decimal.string(from: NSNumber(value: last)) ?? ""
            lastValueLabel.text = currencyInfo.name == "BTC" ? "$\(lastString)" : lastString
        } else {
            lastValueLabel.text = ""
        }

        if let high = currencyInfo.high, let low = currencyInfo.low {
            let highString = NumberFormatter.decimal.string(from: NSNumber(value: high)) ?? "(N/A)"
            let lowString = NumberFormatter.decimal.string(from: NSNumber(value: low)) ?? "(N/A)"
            highAndLowLabel.text = "\(highString) / \(lowString)"
        } else {
            highAndLowLabel.text = ""
        }
    }
}

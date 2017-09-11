import UIKit

class BalanceCell: UITableViewCell {
    static let rowHeight: CGFloat = 60

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currencyBalanceLabel: UILabel!
    @IBOutlet weak var estimatedBTCValueLabel: UILabel!

    func update(currencyInfo: BalanceData.CurrencyInfo) {
        thumbnailImageView.image = UIImage(named: currencyInfo.name)
        currencyNameLabel.text = currencyInfo.longName
        currencyBalanceLabel.text = NumberFormatter.defaultCurrencyNumberFormatter.string(from: NSNumber(value: currencyInfo.balance))
        estimatedBTCValueLabel.text = NumberFormatter.decimalNumberFormatter.string(from: NSNumber(value: currencyInfo.estimatedBTCValue))
    }
}

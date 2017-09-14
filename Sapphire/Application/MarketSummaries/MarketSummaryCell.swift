import UIKit

class MarketSummaryCell: UITableViewCell {
    static let rowHeight: CGFloat = 36

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var lastValueLabel: UILabel!
    @IBOutlet weak var highAndLowLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!

    func update(currencyInfo: MarketSummaryData.CurrencyInfo) {
        thumbnailImageView.image = UIImage(named: currencyInfo.name)
        currencyNameLabel.text = currencyInfo.longName

        volumeLabel.text = NumberFormatter.currency.string(from: NSNumber(value: currencyInfo.baseVolume))

        changeLabel.text = NumberFormatter.percent.string(from: NSNumber(value: currencyInfo.change))
        changeLabel.textColor = currencyInfo.change >= 0 ? .flatGreen : .flatRed

        lastValueLabel.text = NumberFormatter.decimal.string(from: NSNumber(value: currencyInfo.last))

        let highString = NumberFormatter.decimal.string(from: NSNumber(value: currencyInfo.high)) ?? "(N/A)"
        let lowString = NumberFormatter.decimal.string(from: NSNumber(value: currencyInfo.low)) ?? "(N/A)"
        highAndLowLabel.text = "\(highString) / \(lowString)"
    }
}

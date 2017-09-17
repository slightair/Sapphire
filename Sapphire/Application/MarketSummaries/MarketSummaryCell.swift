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

        let valueFormatter: NumberFormatter
        let baseCurrency = currencyInfo.market.components(separatedBy: "-").first ?? ""
        switch baseCurrency {
        case "BTC":
            valueFormatter = .decimal
        case "ETH":
            valueFormatter = .currencyFullBTC
        case "USDT":
            valueFormatter = .currency
        default:
            valueFormatter = .currency
        }

        lastValueLabel.text = valueFormatter.string(from: NSNumber(value: currencyInfo.last))

        let highString = valueFormatter.string(from: NSNumber(value: currencyInfo.high)) ?? "(N/A)"
        let lowString = valueFormatter.string(from: NSNumber(value: currencyInfo.low)) ?? "(N/A)"
        highAndLowLabel.text = "\(highString) / \(lowString)"
    }
}

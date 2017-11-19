import UIKit

final class AssetCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var colorView: UIView!

    var color: UIColor? {
        didSet {
            colorView.backgroundColor = color
        }
    }

    static let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .halfUp
        formatter.positiveSuffix = "%"

        return formatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        nameLabel.textColor = .flatWhite
        percentageLabel.textColor = .flatWhite
    }

    func update(currencyInfo: BalanceData.Item, totalBTCAssets: Double) {
        nameLabel.text = currencyInfo.name
        let percentage = currencyInfo.estimatedBTCValue / (totalBTCAssets * Bitcoin.satoshi) * 100
        percentageLabel.text = AssetCell.percentageFormatter.string(from: NSNumber(value: percentage))
    }
}

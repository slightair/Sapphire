import UIKit

class BalanceCell: UITableViewCell {
    static let rowHeight: CGFloat = 44

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currencyBalanceLabel: UILabel!

    func update(balance: Balance) {
        thumbnailImageView.image = UIImage(named: balance.currency)
        currencyNameLabel.text = balance.currency
        currencyBalanceLabel.text = String(describing: balance.balance)
    }
}

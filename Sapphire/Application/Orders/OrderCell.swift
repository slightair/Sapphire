import UIKit

class OrderCell: UITableViewCell {
    static let rowHeight: CGFloat = 60

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var exchangeLabel: UILabel!
    @IBOutlet weak var orderTypeLabel: UILabel!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    func update(order: Order) {
        thumbnailImageView.image = UIImage(named: order.currency)
        exchangeLabel.text = order.exchange
        orderTypeLabel.text = order.orderType
        limitLabel.text = "\(NumberFormatter.currencyFullBTC.string(from: NSNumber(value: order.limit)) ?? "") \(order.baseCurrency)"
        quantityLabel.text = NumberFormatter.currency.string(from: NSNumber(value: order.quantity))

        let openedString = DateFormatter.default.string(from: order.opened)
        let closedString: String
        if let closed = order.closed {
            closedString = DateFormatter.default.string(from: closed)
        } else {
            closedString = ""
        }
        dateLabel.text = "\(openedString) - \(closedString)"
        priceLabel.text = "\(NumberFormatter.currencyFullBTC.string(from: NSNumber(value: order.price)) ?? "") \(order.baseCurrency)"
        priceLabel.textColor = order.price > 0 ? .flatGreen : .flatRed
    }
}

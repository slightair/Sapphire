import UIKit
import Kingfisher

class OrderCell: UITableViewCell {
    static let rowHeight: CGFloat = 60
    static let placeholderImage = UIImage.fontAwesomeIcon(name: .question, style: .solid, textColor: .systemBlue, size: CGSize(width: 64, height: 64))

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var exchangeLabel: UILabel!
    @IBOutlet weak var orderTypeLabel: UILabel!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var lastValueLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    func update(orderInfo: OrderData.OrderInfo) {
        thumbnailImageView.kf.setImage(with: orderInfo.logoImageURL, placeholder: OrderCell.placeholderImage)
        exchangeLabel.text = orderInfo.exchange
        orderTypeLabel.text = orderInfo.orderType
        limitLabel.text = "\(NumberFormatter.currencyFullBTC.string(from: NSNumber(value: orderInfo.limit)) ?? "") \(orderInfo.baseCurrency)"

        if let last = orderInfo.last {
            lastValueLabel.text = "\(NumberFormatter.currencyFullBTC.string(from: NSNumber(value: last)) ?? "") \(orderInfo.baseCurrency)"
            lastValueLabel.isHidden = false
        } else {
            lastValueLabel.text = nil
            lastValueLabel.isHidden = true
        }
        quantityLabel.text = NumberFormatter.currency.string(from: NSNumber(value: orderInfo.quantity))

        let openedString = DateFormatter.default.string(from: orderInfo.opened)
        let closedString: String
        if let closed = orderInfo.closed {
            closedString = DateFormatter.default.string(from: closed)
        } else {
            closedString = ""
        }
        dateLabel.text = "\(openedString) - \(closedString)"
        priceLabel.text = "\(NumberFormatter.currency.string(from: NSNumber(value: orderInfo.price)) ?? "") \(orderInfo.baseCurrency)"
        priceLabel.textColor = orderInfo.price > 0 ? .systemGreen : .systemRed
    }
}

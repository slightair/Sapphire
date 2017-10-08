import UIKit
import Charts
import ChameleonFramework
import Kingfisher

class BalanceCell: UICollectionViewCell {
    static let numberOfTicks = 96
    static let placeholderImage = UIImage.fontAwesomeIcon(name: .question, textColor: .flatBlue, size: CGSize(width: 64, height: 64))

    class DateValueFormatter: NSObject, IAxisValueFormatter {
        static let timeDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }()

        static let dateDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            return formatter
        }()

        let chart: Chart

        init(chart: Chart) {
            self.chart = chart
        }

        func stringForValue(_ value: Double, axis _: AxisBase?) -> String {
            let index = Int(value)
            let date = chart.ticks[index].date
            let formatter = DateValueFormatter.timeDateFormatter
            return formatter.string(from: date)
        }
    }

    @IBOutlet weak var chartView: CandleStickChartView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currencyBalanceLabel: UILabel!
    @IBOutlet weak var estimatedBTCValueLabel: UILabel!
    @IBOutlet weak var lastValueLabel: UILabel!
    @IBOutlet weak var highAndLowLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        chartView.leftAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawGridLinesEnabled = true
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.labelTextColor = .flatGray
        chartView.xAxis.gridColor = .flatWhite
        chartView.rightAxis.drawAxisLineEnabled = false
        chartView.rightAxis.labelTextColor = .flatGray
        chartView.rightAxis.gridColor = .flatWhite
        chartView.chartDescription?.enabled = false
        chartView.legend.enabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.highlightPerTapEnabled = false
        chartView.highlightPerDragEnabled = false
        chartView.dragEnabled = false
    }

    func update(currencyInfo: BalanceData.CurrencyInfo) {
        thumbnailImageView.kf.setImage(with: currencyInfo.logoImageURL, placeholder: BalanceCell.placeholderImage)
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

        let chart = currencyInfo.chart
        let currencyValueFormatter: IAxisValueFormatter
        if chart.market.hasPrefix("BTC") {
            currencyValueFormatter = DefaultAxisValueFormatter(formatter: .decimal)
        } else {
            currencyValueFormatter = DefaultAxisValueFormatter(formatter: .currency)
        }

        chartView.xAxis.valueFormatter = MarketDetailChartCell.DateValueFormatter(chart: chart)
        chartView.rightAxis.valueFormatter = currencyValueFormatter
        chartView.data = MarketDetailChartCell.candleData(from: chart)
    }

    static func candleData(from chart: Chart) -> CandleChartData {
        let magnification: Double = chart.market.hasPrefix("BTC") ? Bitcoin.satoshi : 1.0
        let entries = chart.ticks.suffix(MarketDetailChartCell.numberOfTicks).enumerated().map { index, record in
            CandleChartDataEntry(x: Double(index),
                                 shadowH: record.high * magnification,
                                 shadowL: record.low * magnification,
                                 open: record.open * magnification,
                                 close: record.close * magnification)
        }

        let dataSet = CandleChartDataSet(values: entries, label: chart.market)
        dataSet.drawValuesEnabled = false
        dataSet.shadowColor = .flatGray
        dataSet.shadowWidth = 0.75
        dataSet.increasingColor = .flatGreen
        dataSet.increasingFilled = true
        dataSet.decreasingColor = .flatRed
        dataSet.decreasingFilled = true
        dataSet.neutralColor = .flatBlue

        return CandleChartData(dataSet: dataSet)
    }

    static func cellSize(forWidth width: CGFloat) -> CGSize {
        let chartHeight: CGFloat = (width - 8 * 2 - 8 * 2) * (7 / 16)
        let summaryHeight: CGFloat = 48
        let cellHeight = 8 * 2 + 4 * 2 + chartHeight + summaryHeight

        return CGSize(width: width, height: cellHeight)
    }
}

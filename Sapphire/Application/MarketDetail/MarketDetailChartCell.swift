import UIKit
import Charts

class MarketDetailChartCell: UITableViewCell {
    static let numberOfTicks: Int = {
        UIScreen.main.traitCollection.horizontalSizeClass == .regular ? 192 : 96
    }()

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

    override func awakeFromNib() {
        super.awakeFromNib()

        chartView.leftAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawGridLinesEnabled = true
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.labelTextColor = .systemGray
        chartView.xAxis.gridColor = .systemBackground
        chartView.rightAxis.drawAxisLineEnabled = false
        chartView.rightAxis.labelTextColor = .systemGray
        chartView.rightAxis.gridColor = .systemBackground
        chartView.chartDescription?.enabled = false
        chartView.legend.enabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.highlightPerTapEnabled = false
        chartView.highlightPerDragEnabled = false
        chartView.dragEnabled = false
    }

    func update(chart: Chart) {
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

        let dataSet = CandleChartDataSet(entries: entries, label: chart.market)
        dataSet.drawValuesEnabled = false
        dataSet.shadowColor = .systemGray
        dataSet.shadowWidth = 0.75
        dataSet.increasingColor = .systemGreen
        dataSet.increasingFilled = true
        dataSet.decreasingColor = .systemRed
        dataSet.decreasingFilled = true
        dataSet.neutralColor = .systemBlue

        return CandleChartData(dataSet: dataSet)
    }
}

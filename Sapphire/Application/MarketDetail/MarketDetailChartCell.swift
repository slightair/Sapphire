import UIKit
import Charts

class MarketDetailChartCell: UITableViewCell {
    static let numberOfTicks = 48

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

    class DecimalValueFormatter: NSObject, IAxisValueFormatter {
        let chart: Chart

        init(chart: Chart) {
            self.chart = chart
        }

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return NumberFormatter.decimal.string(from: NSNumber(value: value))!
        }
    }

    @IBOutlet weak var chartView: CandleStickChartView!

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

    func update(chart: Chart) {
        chartView.xAxis.valueFormatter = MarketDetailChartCell.DateValueFormatter(chart: chart)
        chartView.rightAxis.valueFormatter = MarketDetailChartCell.DecimalValueFormatter(chart: chart)
        chartView.data = MarketDetailChartCell.candleData(from: chart)
    }

    static func candleData(from chart: Chart) -> CandleChartData {
        let magnification: Double = Bitcoin.satoshi
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

}

import UIKit
import RxSwift
import RxCocoa
import ChameleonFramework
import FontAwesome_swift
import Whisper
import Charts
import MBProgressHUD

final class AssetsViewController: UIViewController, AssetsViewProtocol {
    private var presenter: AssetsPresenterProtocol!

    private let refreshTriggerSubject = PublishSubject<Void>()
    var refreshTrigger: Driver<Void> {
        return refreshTriggerSubject.asDriver(onErrorRecover: { _ in .never() })
    }

    private let disposeBag = DisposeBag()

    private var chartView: PieChartView!

    func inject(presenter: AssetsPresenterProtocol) {
        self.presenter = presenter
    }

    init() {
        super.init(nibName: nil, bundle: nil)

        tabBarItem.image = UIImage.fontAwesomeIcon(name: .pieChart, textColor: .white, size: CGSize(width: 32, height: 32))
        tabBarItem.title = "Assets"
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Assets"
        view.backgroundColor = .white

        setUpChartView()

        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: nil)
        navigationItem.rightBarButtonItem = refreshButton

        Observable.of(
            rx.sentMessage(#selector(viewWillAppear)).take(1).map { _ in },
            refreshButton.rx.tap.map { _ in }
        )
        .merge()
        .do(onNext: { [weak self] _ in
            guard let view = self?.navigationController?.view else { return }
            MBProgressHUD.showAdded(to: view, animated: true)
        })
        .bind(to: refreshTriggerSubject)
        .disposed(by: disposeBag)

        presenter.balanceData
            .map(AssetsViewController.pieChartData)
            .drive(onNext: { [weak self] data in
                self?.chartView.data = data
            })
            .disposed(by: disposeBag)

        Driver.of(presenter.balanceData.map { _ in false }, presenter.errors.map { _ in false })
            .merge()
            .drive(onNext: { [weak self] _ in
                guard let view = self?.navigationController?.view else { return }
                MBProgressHUD.hide(for: view, animated: true)
            })
            .disposed(by: disposeBag)

        presenter.errors
            .drive(onNext: { [weak self] error in
                guard let navigationController = self?.navigationController else { return }
                let message = Message(title: error.localizedDescription, textColor: .flatWhite, backgroundColor: .flatRed)
                Whisper.show(whisper: message, to: navigationController)
            })
            .disposed(by: disposeBag)
    }

    private func setUpChartView() {
        chartView = PieChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chartView)

        chartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        chartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        chartView.chartDescription?.enabled = false
        chartView.drawHoleEnabled = false
        chartView.usePercentValuesEnabled = true
        chartView.isUserInteractionEnabled = false
    }

    static func pieChartData(from balanceData: BalanceData) -> PieChartData {
        let values = balanceData.items.map { currencyInfo in
            PieChartDataEntry(value: Double(currencyInfo.estimatedBTCValue), label: currencyInfo.name)
        }

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .halfUp
        formatter.positiveSuffix = "%"

        let dataSet = PieChartDataSet(values: values, label: nil)
        dataSet.colors = [
            .flatMint,
            .flatGreen,
            .flatLime,
            .flatSkyBlue,
            .flatMagenta,
            .flatRed,
            .flatOrange,
            .flatYellow,
        ]
        dataSet.valueFormatter = DefaultValueFormatter(formatter: formatter)
        let data = PieChartData(dataSet: dataSet)

        return data
    }
}

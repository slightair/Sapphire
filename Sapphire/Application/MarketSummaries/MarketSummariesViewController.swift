import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import JGProgressHUD

final class MarketSummariesViewController: UITableViewController, MarketSummariesViewProtocol {
    private var presenter: MarketSummariesPresenterProtocol!

    private let refreshTriggerSubject = PublishSubject<Void>()
    var refreshTrigger: Driver<Void> {
        return refreshTriggerSubject.asDriver(onErrorRecover: { _ in .never() })
    }

    private let selectedMarketSubject = PublishSubject<String>()
    var selectedMarket: Driver<String> {
        return selectedMarketSubject.asDriver(onErrorRecover: { _ in .never() })
    }

    private let disposeBag = DisposeBag()

    func inject(presenter: MarketSummariesPresenterProtocol) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Market"

        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: nil)
        navigationItem.rightBarButtonItem = refreshButton

        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl

        let loadingView = JGProgressHUD(style: .dark)
        loadingView.textLabel.text = "Loading"

        Observable.of(
            rx.sentMessage(#selector(viewWillAppear)).take(1).map { _ in },
            refreshControl.rx.controlEvent(.valueChanged).map { _ in },
            refreshButton.rx.tap.map { _ in }
        )
        .merge()
        .do(onNext: { [weak self] _ in
            guard let view = self?.navigationController?.view else { return }
            loadingView.show(in: view)
        })
        .bind(to: refreshTriggerSubject)
        .disposed(by: disposeBag)

        tableView.rowHeight = MarketSummaryCell.rowHeight
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.registerFromNib(of: MarketSummaryCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil

        let dataSource = RxTableViewSectionedReloadDataSource<MarketSummaryData>(
            configureCell: { _, tableView, indexPath, currencyInfo in
                let cell: MarketSummaryCell = tableView.dequeueReusableCell(for: indexPath)
                cell.update(currencyInfo: currencyInfo)
                return cell
            },
            titleForHeaderInSection: { dataSource, index in
                let data = dataSource.sectionModels[index]
                let dateString = DateFormatter.default.string(from: data.date)
                return "\(data.marketGroup) - \(dateString)"
            },
            sectionIndexTitles: { dataSource in
                dataSource.sectionModels.compactMap { $0.marketGroup.first }.map { String($0) }
            }
        )

        presenter.marketSummaryData
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        Driver.of(presenter.marketSummaryData.map { _ in false }, presenter.errors.map { _ in false })
            .merge()
            .do(onNext: { _ in
                loadingView.dismiss()
            })
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)

        presenter.errors
            .drive(onNext: { [weak self] error in
                guard let view = self?.navigationController?.view else { return }
                let errorView = JGProgressHUD(style: .dark)
                errorView.textLabel.text = "Error"
                errorView.detailTextLabel.text = error.localizedDescription
                errorView.indicatorView = JGProgressHUDErrorIndicatorView()
                errorView.show(in: view)
                errorView.dismiss(afterDelay: 3.0)
            })
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(MarketSummaryData.CurrencyInfo.self)
            .map { $0.market }
            .bind(to: selectedMarketSubject)
            .disposed(by: disposeBag)
    }
}

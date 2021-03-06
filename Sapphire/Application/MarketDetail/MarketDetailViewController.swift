import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import JGProgressHUD

final class MarketDetailViewController: UITableViewController, MarketDetailViewProtocol {
    private var presenter: MarketDetailPresenterProtocol!

    private let refreshTriggerSubject = PublishSubject<Void>()
    var refreshTrigger: Driver<Void> {
        return refreshTriggerSubject.asDriver(onErrorRecover: { _ in .never() })
    }

    private let disposeBag = DisposeBag()

    func inject(presenter: MarketDetailPresenterProtocol) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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

        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.registerFromNib(of: MarketSummaryCell.self)
        tableView.registerFromNib(of: MarketDetailChartCell.self)
        tableView.registerFromNib(of: OrderCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil

        let dataSource = RxTableViewSectionedReloadDataSource<MarketDetailData.Section>(
            configureCell: { dataSource, tableView, indexPath, _ in
                let data = dataSource[indexPath]
                switch data {
                case let .chartSectionItem(chart):
                    let cell: MarketDetailChartCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.update(chart: chart)
                    return cell
                case let .summarySectionItem(currencyInfo):
                    let cell: MarketSummaryCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.update(currencyInfo: currencyInfo)
                    cell.selectionStyle = .none
                    return cell
                case let .openOrdersSectionItem(orderInfo):
                    let cell: OrderCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.update(orderInfo: orderInfo)
                    return cell
                case let .orderHistorySectionItem(orderInfo):
                    let cell: OrderCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.update(orderInfo: orderInfo)
                    return cell
                }
            },
            titleForHeaderInSection: { dataSource, index in
                let data = dataSource.sectionModels[index]
                return data.title
            }
        )

        presenter.marketDetailData
            .map { $0.sections }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        Driver.of(presenter.marketDetailData.map { _ in false }, presenter.errors.map { _ in false })
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
    }
}

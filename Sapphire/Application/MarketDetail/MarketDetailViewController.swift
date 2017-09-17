import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Whisper

final class MarketDetailViewController: UITableViewController, MarketDetailViewProtocol {
    private var presenter: MarketDetailPresenterProtocol!

    fileprivate let refreshTriggerSubject = PublishSubject<Void>()
    var refreshTrigger: Driver<Void> {
        return refreshTriggerSubject.asDriver(onErrorRecover: { _ in .never() })
    }

    private var dataSource = RxTableViewSectionedReloadDataSource<MarketDetailData.Section>()
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

        Observable.of(
            rx.sentMessage(#selector(viewWillAppear)).map { _ in },
            refreshControl.rx.controlEvent(.valueChanged).map { _ in },
            refreshButton.rx.tap.map { _ in }
        )
        .merge()
        .bind(to: refreshTriggerSubject)
        .disposed(by: disposeBag)

        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.registerFromNib(of: MarketSummaryCell.self)
        tableView.registerFromNib(of: MarketDetailChartCell.self)
        tableView.registerFromNib(of: OrderCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil

        dataSource.configureCell = { dataSource, tableView, indexPath, _ in
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
        }

        dataSource.titleForHeaderInSection = { dataSource, index in
            let data = dataSource.sectionModels[index]
            return data.title
        }

        presenter.marketDetailData
            .map { $0.sections }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        Driver.of(presenter.marketDetailData.map { _ in false }, presenter.errors.map { _ in false })
            .merge()
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)

        presenter.errors
            .drive(onNext: { [weak self] error in
                guard let navigationController = self?.navigationController else { return }
                let message = Message(title: error.localizedDescription, textColor: .flatWhite, backgroundColor: .flatRed)
                Whisper.show(whisper: message, to: navigationController)
            })
            .disposed(by: disposeBag)
    }
}

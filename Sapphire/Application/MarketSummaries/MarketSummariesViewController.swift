import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Whisper

final class MarketSummariesViewController: UITableViewController, MarketSummariesViewProtocol {
    private var presenter: MarketSummariesPresenterProtocol!

    fileprivate let refreshTriggerSubject = PublishSubject<Void>()
    var refreshTrigger: Driver<Void> {
        return refreshTriggerSubject.asDriver(onErrorRecover: { _ in .never() })
    }

    private var dataSource = RxTableViewSectionedReloadDataSource<MarketSummaryData>()
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

        Observable.of(
            rx.sentMessage(#selector(viewWillAppear)).map { _ in },
            refreshControl.rx.controlEvent(.valueChanged).map { _ in },
            refreshButton.rx.tap.map { _ in }
        )
        .merge()
        .bind(to: refreshTriggerSubject)
        .disposed(by: disposeBag)

        tableView.rowHeight = MarketSummaryCell.rowHeight
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.registerFromNib(of: MarketSummaryCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil

        dataSource.configureCell = { _, tableView, indexPath, currencyInfo in
            let cell: MarketSummaryCell = tableView.dequeueReusableCell(for: indexPath)
            cell.update(currencyInfo: currencyInfo)
            return cell
        }

        dataSource.titleForHeaderInSection = { dataSource, index in
            let data = dataSource.sectionModels[index]
            let dateString = DateFormatter.default.string(from: data.date)
            return "\(data.marketGroup) - \(dateString)"
        }

        dataSource.sectionIndexTitles = { dataSource in
            dataSource.sectionModels.flatMap { $0.marketGroup.first }.map { String($0) }
        }

        presenter.marketSummaryData
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        Driver.of(presenter.marketSummaryData.map { _ in false }, presenter.errors.map { _ in false })
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

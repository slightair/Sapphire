import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import ChameleonFramework
import FontAwesome_swift
import Whisper

final class BalancesViewController: UITableViewController, BalancesViewProtocol {
    private var presenter: BalancesPresenterProtocol!

    fileprivate let refreshTriggerSubject = PublishSubject<Void>()
    var refreshTrigger: Driver<Void> {
        return refreshTriggerSubject.asDriver(onErrorRecover: { _ in .never() })
    }

    private var dataSource = RxTableViewSectionedReloadDataSource<BalanceData>()
    private let disposeBag = DisposeBag()

    func inject(presenter: BalancesPresenterProtocol) {
        self.presenter = presenter
    }

    init() {
        super.init(style: .plain)

        tabBarItem.image = UIImage.fontAwesomeIcon(name: .bitcoin, textColor: .white, size: CGSize(width: 32, height: 32))
        tabBarItem.title = "Balances"
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Balances"

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

        tableView.rowHeight = BalanceCell.rowHeight
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.registerFromNib(of: BalanceCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil

        dataSource.configureCell = { _, tableView, indexPath, currencyInfo in
            let cell: BalanceCell = tableView.dequeueReusableCell(for: indexPath)
            cell.update(currencyInfo: currencyInfo)
            return cell
        }

        dataSource.titleForHeaderInSection = { dataSource, index in
            let data = dataSource.sectionModels[index]
            let dateString = DateFormatter.default.string(from: data.date)
            let usdtAssets = NumberFormatter.currency.string(from: NSNumber(value: data.usdtAssets)) ?? ""
            let btcAssets = NumberFormatter.currency.string(from: NSNumber(value: data.btcAssets)) ?? ""

            return "\(dateString) - \(btcAssets) / $\(usdtAssets)"
        }

        presenter.balanceData
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        Driver.of(presenter.balanceData.map { _ in false }, presenter.errors.map { _ in false })
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

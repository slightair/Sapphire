import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import FontAwesome_swift
import Whisper
import MBProgressHUD

final class OrdersViewController: UITableViewController, OrdersViewProtocol {
    private var presenter: OrdersPresenterProtocol!

    private let refreshTriggerSubject = PublishSubject<Void>()
    var refreshTrigger: Driver<Void> {
        return refreshTriggerSubject.asDriver(onErrorRecover: { _ in .never() })
    }

    private let selectedMarketSubject = PublishSubject<String>()
    var selectedMarket: Driver<String> {
        return selectedMarketSubject.asDriver(onErrorRecover: { _ in .never() })
    }

    private let disposeBag = DisposeBag()

    func inject(presenter: OrdersPresenterProtocol) {
        self.presenter = presenter
    }

    init() {
        super.init(style: .plain)

        tabBarItem.image = UIImage.fontAwesomeIcon(name: .calendar, textColor: .white, size: CGSize(width: 32, height: 32))
        tabBarItem.title = "Orders"
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Orders"

        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: nil)
        navigationItem.rightBarButtonItem = refreshButton

        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl

        Observable.of(
            rx.sentMessage(#selector(viewWillAppear)).take(1).map { _ in },
            refreshControl.rx.controlEvent(.valueChanged).map { _ in },
            refreshButton.rx.tap.map { _ in }
        )
        .merge()
        .do(onNext: { [weak self] _ in
            guard let view = self?.navigationController?.view else { return }
            MBProgressHUD.showAdded(to: view, animated: true)
        })
        .bind(to: refreshTriggerSubject)
        .disposed(by: disposeBag)

        tableView.rowHeight = OrderCell.rowHeight
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.registerFromNib(of: OrderCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil

        let dataSource = RxTableViewSectionedReloadDataSource<OrderData>(
            configureCell: { _, tableView, indexPath, orderInfo in
                let cell: OrderCell = tableView.dequeueReusableCell(for: indexPath)
                cell.update(orderInfo: orderInfo)
                return cell
            },
            titleForHeaderInSection: { dataSource, index in
                let data = dataSource.sectionModels[index]
                return data.group
            }
        )

        presenter.orderData
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        Driver.of(presenter.orderData.map { _ in false }, presenter.errors.map { _ in false })
            .merge()
            .do(onNext: { [weak self] _ in
                guard let view = self?.navigationController?.view else { return }
                MBProgressHUD.hide(for: view, animated: true)
            })
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)

        presenter.errors
            .drive(onNext: { [weak self] error in
                guard let navigationController = self?.navigationController else { return }
                let message = Message(title: error.localizedDescription, textColor: .flatWhite, backgroundColor: .flatRed)
                Whisper.show(whisper: message, to: navigationController)
            })
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(OrderData.OrderInfo.self)
            .map { $0.exchange }
            .bind(to: selectedMarketSubject)
            .disposed(by: disposeBag)
    }
}

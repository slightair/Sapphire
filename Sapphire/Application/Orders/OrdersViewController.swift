import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import FontAwesome_swift
import Whisper

final class OrdersViewController: UITableViewController, OrdersViewProtocol {
    private var presenter: OrdersPresenterProtocol!

    fileprivate let refreshTriggerSubject = PublishSubject<Void>()
    var refreshTrigger: Driver<Void> {
        return refreshTriggerSubject.asDriver(onErrorRecover: { _ in .never() })
    }

    private var dataSource = RxTableViewSectionedReloadDataSource<OrderData>()
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
            rx.sentMessage(#selector(viewWillAppear)).map { _ in },
            refreshControl.rx.controlEvent(.valueChanged).map { _ in },
            refreshButton.rx.tap.map { _ in }
        )
        .merge()
        .bind(to: refreshTriggerSubject)
        .disposed(by: disposeBag)

        tableView.rowHeight = OrderCell.rowHeight
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.registerFromNib(of: OrderCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil

        dataSource.configureCell = { _, tableView, indexPath, order in
            let cell: OrderCell = tableView.dequeueReusableCell(for: indexPath)
            cell.update(order: order)
            return cell
        }

        dataSource.titleForHeaderInSection = { dataSource, index in
            let data = dataSource.sectionModels[index]
            return data.group
        }

        presenter.orderData
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        Driver.of(presenter.orderData.map { _ in false }, presenter.errors.map { _ in false })
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
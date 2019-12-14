import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import FontAwesome
import JGProgressHUD

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

        tabBarItem.image = UIImage.fontAwesomeIcon(name: .calendar, style: .solid, textColor: .white, size: CGSize(width: 32, height: 32))
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

        tableView.rx.modelSelected(OrderData.OrderInfo.self)
            .map { $0.exchange }
            .bind(to: selectedMarketSubject)
            .disposed(by: disposeBag)
    }
}

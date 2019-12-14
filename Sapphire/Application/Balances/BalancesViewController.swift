import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import FontAwesome
import JGProgressHUD

final class BalancesViewController: UICollectionViewController, BalancesViewProtocol {
    private var presenter: BalancesPresenterProtocol!

    private let refreshTriggerSubject = PublishSubject<Void>()
    var refreshTrigger: Driver<Void> {
        return refreshTriggerSubject.asDriver(onErrorRecover: { _ in .never() })
    }

    private let disposeBag = DisposeBag()

    func inject(presenter: BalancesPresenterProtocol) {
        self.presenter = presenter
    }

    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())

        tabBarItem.image = UIImage.fontAwesomeIcon(name: .bitcoin, style: .brands, textColor: .white, size: CGSize(width: 32, height: 32))
        tabBarItem.title = "Balances"
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Balances"

        guard let collectionView = collectionView else {
            fatalError("CollectionView not found")
        }

        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: nil)
        navigationItem.rightBarButtonItem = refreshButton

        let refreshControl = UIRefreshControl()
        collectionView.refreshControl = refreshControl

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

        collectionView.registerFromNib(of: BalanceCell.self)
        collectionView.registerFromNib(of: BalancesSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        collectionView.delegate = nil
        collectionView.dataSource = nil
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false

        guard let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("Invalid collection view settings")
        }
        layout.headerReferenceSize = CGSize(width: 0, height: BalancesSectionHeaderView.height)
        layout.sectionHeadersPinToVisibleBounds = true

        let dataSource = RxCollectionViewSectionedReloadDataSource<BalanceData>(
            configureCell: { _, collectionView, indexPath, currencyInfo in
                let cell: BalanceCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.update(currencyInfo: currencyInfo)
                return cell
            },
            configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
                guard kind == UICollectionView.elementKindSectionHeader else {
                    fatalError("Unexpected supplementaryView kind: \(kind)")
                }

                let data = dataSource.sectionModels[indexPath.section]
                let dateString = DateFormatter.default.string(from: data.date)
                let usdtAssets = NumberFormatter.currency.string(from: NSNumber(value: data.usdtAssets)) ?? ""
                let btcAssets = NumberFormatter.currency.string(from: NSNumber(value: data.btcAssets)) ?? ""

                let view: BalancesSectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: indexPath)
                view.titleLabel.text = "\(dateString) - \(btcAssets) / $\(usdtAssets)"

                return view
            }
        )

        presenter.balanceData
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        Driver.of(presenter.balanceData.map { _ in false }, presenter.errors.map { _ in false })
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateCellSizes()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        updateCellSizes(viewWidth: size.width)
    }

    func updateCellSizes(viewWidth: CGFloat? = nil) {
        guard let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        let numberOfGridsPerRow = traitCollection.horizontalSizeClass == .regular ? 3 : 1
        let space: CGFloat = 1.0
        let inset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)

        var length = viewWidth ?? view.bounds.width
        length -= space * CGFloat(numberOfGridsPerRow - 1)
        length -= inset.left + inset.right

        let side = length / CGFloat(numberOfGridsPerRow)
        guard side > 0.0 else {
            return
        }

        layout.itemSize = BalanceCell.cellSize(forWidth: side)
        layout.minimumLineSpacing = space
        layout.minimumInteritemSpacing = space
        layout.sectionInset = inset
        layout.invalidateLayout()
    }
}

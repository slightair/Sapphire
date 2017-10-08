import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import ChameleonFramework
import FontAwesome_swift
import Whisper
import MBProgressHUD

final class BalancesViewController: UICollectionViewController, BalancesViewProtocol {
    private var presenter: BalancesPresenterProtocol!

    private let refreshTriggerSubject = PublishSubject<Void>()
    var refreshTrigger: Driver<Void> {
        return refreshTriggerSubject.asDriver(onErrorRecover: { _ in .never() })
    }

    private var dataSource = RxCollectionViewSectionedReloadDataSource<BalanceData>()
    private let disposeBag = DisposeBag()

    func inject(presenter: BalancesPresenterProtocol) {
        self.presenter = presenter
    }

    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())

        tabBarItem.image = UIImage.fontAwesomeIcon(name: .bitcoin, textColor: .white, size: CGSize(width: 32, height: 32))
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

        collectionView.registerFromNib(of: BalanceCell.self)
        collectionView.registerFromNib(of: BalancesSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.delegate = nil
        collectionView.dataSource = nil
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false

        guard let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("Invalid collection view settings")
        }
        layout.headerReferenceSize = CGSize(width: 0, height: BalancesSectionHeaderView.height)
        layout.sectionHeadersPinToVisibleBounds = true

        dataSource.configureCell = { _, collectionView, indexPath, currencyInfo in
            let cell: BalanceCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.update(currencyInfo: currencyInfo)
            return cell
        }

        dataSource.supplementaryViewFactory = { dataSource, collectionView, kind, indexPath in
            guard kind == UICollectionElementKindSectionHeader else {
                fatalError("Unexpected supplementaryView kind: \(kind)")
            }

            let data = dataSource.sectionModels[indexPath.section]
            let dateString = DateFormatter.default.string(from: data.date)
            let usdtAssets = NumberFormatter.currency.string(from: NSNumber(value: data.usdtAssets)) ?? ""
            let btcAssets = NumberFormatter.currency.string(from: NSNumber(value: data.btcAssets)) ?? ""

            let view: BalancesSectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, for: indexPath)
            view.titleLabel.text = "\(dateString) - \(btcAssets) / $\(usdtAssets)"

            return view
        }

        presenter.balanceData
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        Driver.of(presenter.balanceData.map { _ in false }, presenter.errors.map { _ in false })
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

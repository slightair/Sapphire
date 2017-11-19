import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import ChameleonFramework
import FontAwesome_swift
import Whisper
import MBProgressHUD
import YMTreeMap

final class AssetsViewController: UICollectionViewController, AssetsViewProtocol {
    private var presenter: AssetsPresenterProtocol!

    private let refreshTriggerSubject = PublishSubject<Void>()
    var refreshTrigger: Driver<Void> {
        return refreshTriggerSubject.asDriver(onErrorRecover: { _ in .never() })
    }

    private let disposeBag = DisposeBag()

    func inject(presenter: AssetsPresenterProtocol) {
        self.presenter = presenter
    }

    init() {
        super.init(collectionViewLayout: Layout())

        tabBarItem.image = UIImage.fontAwesomeIcon(name: .pieChart, textColor: .white, size: CGSize(width: 32, height: 32))
        tabBarItem.title = "Assets"
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Assets"

        guard let collectionView = collectionView else {
            fatalError("CollectionView not found")
        }

        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: nil)
        navigationItem.rightBarButtonItem = refreshButton

        Observable.of(
            rx.sentMessage(#selector(viewWillAppear)).take(1).map { _ in },
            refreshButton.rx.tap.map { _ in }
        )
        .merge()
        .do(onNext: { [weak self] _ in
            guard let view = self?.navigationController?.view else { return }
            MBProgressHUD.showAdded(to: view, animated: true)
        })
        .bind(to: refreshTriggerSubject)
        .disposed(by: disposeBag)

        collectionView.registerFromNib(of: AssetCell.self)
        collectionView.delegate = nil
        collectionView.dataSource = nil
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false

        let colors: [UIColor] = [
            UIColor.flatMint,
            UIColor.flatGreen,
            UIColor.flatLime,
            UIColor.flatSkyBlue,
            UIColor.flatMagenta,
            UIColor.flatRed,
            UIColor.flatOrange,
            UIColor.flatYellow,
        ].map { color in
            var h: CGFloat = 0.0
            var s: CGFloat = 0.0
            var b: CGFloat = 0.0
            var a: CGFloat = 0.0
            color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)

            return UIColor(hue: h, saturation: s - 0.2, brightness: b, alpha: a)
        }

        let dataSource = RxCollectionViewSectionedReloadDataSource<BalanceData>(
            configureCell: { dataSource, collectionView, indexPath, currencyInfo in
                let data = dataSource.sectionModels[indexPath.section]
                let cell: AssetCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.update(currencyInfo: currencyInfo, totalBTCAssets: data.btcAssets)
                cell.color = colors[indexPath.row % colors.count]
                return cell
            },
            configureSupplementaryView: { _, _, _, _ in UICollectionReusableView() }
        )

        presenter.balanceData
            .do(onNext: { [weak self] balanceDataList in
                if let balanceData = balanceDataList.first {
                    self?.updateCellLayout(for: balanceData, viewSize: self?.collectionView?.contentSize ?? .zero)
                }
            })
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        Driver.of(presenter.balanceData.map { _ in false }, presenter.errors.map { _ in false })
            .merge()
            .drive(onNext: { [weak self] _ in
                guard let view = self?.navigationController?.view else { return }
                MBProgressHUD.hide(for: view, animated: true)
            })
            .disposed(by: disposeBag)

        presenter.errors
            .drive(onNext: { [weak self] error in
                guard let navigationController = self?.navigationController else { return }
                let message = Message(title: error.localizedDescription, textColor: .flatWhite, backgroundColor: .flatRed)
                Whisper.show(whisper: message, to: navigationController)
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(
            rx.sentMessage(#selector(viewWillTransition(to:with:))),
            presenter.balanceData.asObservable()
        )
            .subscribe(onNext: { [weak self] arguments, balanceDataList in
                guard let size = arguments[0] as? CGSize else {
                    return
                }

                if let balanceData = balanceDataList.first {
                    self?.updateCellLayout(for: balanceData, viewSize: size)
                }
            })
            .disposed(by: disposeBag)
    }

    private func updateCellLayout(for balanceData: BalanceData, viewSize: CGSize) {
        let treeMap = YMTreeMap(withValues: balanceData.items.map { $0.estimatedBTCValue })
        treeMap.alignment = .RetinaSubPixel
        if let layout = collectionViewLayout as? Layout {
            let navigationBarHeight: CGFloat = 44
            let tabBarHeight: CGFloat = 44
            let treeMapHeight = viewSize.height - (UIApplication.shared.statusBarFrame.height + navigationBarHeight + tabBarHeight)
            let rect = CGRect(x: 0, y: 0, width: viewSize.width, height: treeMapHeight)
            layout.rects = treeMap.tessellate(inRect: rect)
        }
    }

    final class Layout: UICollectionViewLayout {
        var rects = [CGRect]() {
            didSet {
                invalidateLayout()
            }
        }

        override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
            return true
        }

        override var collectionViewContentSize: CGSize {
            return self.collectionView?.frame.size ?? .zero
        }

        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            var index = 0
            return rects.flatMap { (itemRect: CGRect) -> UICollectionViewLayoutAttributes? in
                let attrs = rect.intersects(itemRect) ? self.layoutAttributesForItem(at: IndexPath(item: index, section: 0)) : nil
                index += 1
                return attrs
            }
        }

        override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attrs.frame = rects[indexPath.item]
            return attrs
        }
    }
}

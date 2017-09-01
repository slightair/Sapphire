import UIKit
import RxSwift
import RxCocoa

final class BalancesViewController: UIViewController, BalancesViewProtocol {
    private var presenter: BalancesPresenterProtocol!

    private let disposeBag = DisposeBag()

    func inject(presenter: BalancesPresenterProtocol) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Insert code here to connect presenter
    }
}

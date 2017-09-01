import Foundation
import RxSwift
import RxCocoa

final class BalancesPresenter: BalancesPresenterProtocol {
    private weak var view: BalancesViewProtocol!
    private let interactor: BalancesInteractorProtocol
    private let wireframe: BalancesWireframeProtocol

    private let disposeBag = DisposeBag()

    init(view: BalancesViewProtocol, interactor: BalancesInteractorProtocol, wireframe: BalancesWireframeProtocol) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe

        // Insert code here for presenter logic
    }
}

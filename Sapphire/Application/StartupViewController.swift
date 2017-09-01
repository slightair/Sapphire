import UIKit

final class StartupViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presentMainTabView()
    }

    private func presentMainTabView() {
        let viewController = MainTabBarControllerControllerBuilder.build()
        viewController.modalTransitionStyle = .crossDissolve
        present(viewController, animated: true, completion: nil)
    }
}

import UIKit

class LogViewerViewController: UIViewController, UITableViewDataSource {
    let logDataSource: LogDataSource

    let tableView = UITableView()
    let activityIndicatorView = UIActivityIndicatorView()
    let activityIndicatorBackgroundView = UIView()

    var isLoading = false {
        didSet {
            activityIndicatorBackgroundView.isHidden = !isLoading
        }
    }

    init(logDataSource: LogDataSource) {
        self.logDataSource = logDataSource

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSubviews()

        refresh()
    }

    @objc private func refresh() {
        isLoading = true
        logDataSource.load { _ in
            self.tableView.reloadData()
            self.isLoading = false
        }
    }

    private func setUpSubviews() {
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        navigationItem.rightBarButtonItem = refreshButton

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        tableView.register(LogCell.self, forCellReuseIdentifier: LogCell.defaultIdentifier)

        tableView.dataSource = self

        activityIndicatorView.activityIndicatorViewStyle = .whiteLarge
        activityIndicatorView.startAnimating()

        activityIndicatorBackgroundView.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.centerXAnchor.constraint(equalTo: activityIndicatorBackgroundView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: activityIndicatorBackgroundView.centerYAnchor).isActive = true

        activityIndicatorBackgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)

        view.addSubview(activityIndicatorBackgroundView)
        activityIndicatorBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorBackgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        activityIndicatorBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        activityIndicatorBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        activityIndicatorBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return logDataSource.logs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LogCell.defaultIdentifier, for: indexPath) as? LogCell else {
            fatalError("Unexpected cell")
        }

        cell.log = logDataSource.logs[indexPath.row]

        return cell
    }
}

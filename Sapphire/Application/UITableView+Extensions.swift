import UIKit

extension UITableView {
    func registerFromNib(of type: UITableViewCell.Type) {
        guard let className = type.description().components(separatedBy: ".").last else {
            fatalError("Unknown error")
        }

        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forCellReuseIdentifier: className)
    }

    func dequeueReusableCell<CellType: UITableViewCell>(for indexPath: IndexPath) -> CellType {
        guard let className = CellType.description().components(separatedBy: ".").last else {
            fatalError("Unknown error")
        }

        guard let cell = dequeueReusableCell(withIdentifier: className, for: indexPath) as? CellType else {
            fatalError("Invalid cell type specified \"\(className)\"")
        }

        return cell
    }
}

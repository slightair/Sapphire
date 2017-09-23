import UIKit

extension UICollectionView {
    func registerFromNib(of type: UICollectionViewCell.Type) {
        guard let className = type.description().components(separatedBy: ".").last else {
            fatalError("Unknown error")
        }

        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forCellWithReuseIdentifier: className)
    }

    func registerFromNib(of type: UICollectionReusableView.Type, forSupplementaryViewOfKind kind: String) {
        guard let className = type.description().components(separatedBy: ".").last else {
            fatalError("Unknown error")
        }

        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: className)
    }

    func dequeueReusableCell<CellType: UICollectionViewCell>(for indexPath: IndexPath) -> CellType {
        guard let className = CellType.description().components(separatedBy: ".").last else {
            fatalError("Unknown error")
        }

        guard let cell = dequeueReusableCell(withReuseIdentifier: className, for: indexPath) as? CellType else {
            fatalError("Invalid cell type specified \"\(className)\"")
        }

        return cell
    }

    func dequeueReusableSupplementaryView<SupplementaryViewType: UICollectionReusableView>(ofKind kind: String, for indexPath: IndexPath) -> SupplementaryViewType {
        guard let className = SupplementaryViewType.description().components(separatedBy: ".").last else {
            fatalError("Unknown error")
        }

        guard let supplementaryView = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: className, for: indexPath) as? SupplementaryViewType else {
            fatalError("Invalid supplementaryView type specified \"\(className)\"")
        }

        return supplementaryView
    }
}

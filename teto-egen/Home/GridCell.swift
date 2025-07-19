import UIKit

class GridCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor.systemGray4
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(color: UIColor) {
        contentView.backgroundColor = color
    }
}

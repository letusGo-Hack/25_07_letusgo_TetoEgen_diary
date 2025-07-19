import UIKit

enum ColorType {
    case empty
    case pink(Int)  // 1,2,3 단계
    case blue(Int)  // 1,2,3 단계
}

private let pinkColors: [UIColor] = [
    UIColor(red: 1.0, green: 0.92, blue: 0.96, alpha: 1),    // pastel pink1
    UIColor(red: 1.0, green: 0.78, blue: 0.89, alpha: 1),    // pastel pink2
    UIColor(red: 0.94, green: 0.53, blue: 0.74, alpha: 1)    // pastel pink3
]
private let blueColors: [UIColor] = [
    UIColor(red: 0.89, green: 0.94, blue: 1.0, alpha: 1),    // pastel blue1
    UIColor(red: 0.72, green: 0.85, blue: 1.0, alpha: 1),    // pastel blue2
    UIColor(red: 0.47, green: 0.72, blue: 0.98, alpha: 1)    // pastel blue3
]

class GridCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        // Remove default background as per instructions
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(type: ColorType) {
        switch type {
        case .empty:
            contentView.backgroundColor = .clear
            contentView.layer.borderWidth = 2
            contentView.layer.borderColor = UIColor.systemGray3.cgColor
        case .pink(let level):
            let idx = max(0, min(level - 1, 2))
            contentView.backgroundColor = pinkColors[idx]
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = nil
        case .blue(let level):
            let idx = max(0, min(level - 1, 2))
            contentView.backgroundColor = blueColors[idx]
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = nil
        }
    }
    
    @available(*, deprecated, message: "Use configure(type:) instead")
    func configure(color: UIColor) {
        if color == UIColor.clear {
            configure(type: .empty)
        } else if color == UIColor.systemBlue {
            configure(type: .blue(2))
        } else if color == UIColor.systemPink {
            configure(type: .pink(2))
        } else {
            configure(type: .pink(2))
        }
    }
}

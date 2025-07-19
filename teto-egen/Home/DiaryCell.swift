import UIKit
import Then
import SnapKit

final class DiaryCell: UITableViewCell {

    // MARK: - UI Components
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = .label
        return label
    }()

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupViews() {
        accessoryType = .disclosureIndicator
        selectionStyle = .none
        contentView.addSubview(dateLabel)
        contentView.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.lessThanOrEqualToSuperview().inset(60)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(2)
            make.left.equalTo(dateLabel)
            make.right.lessThanOrEqualToSuperview().inset(60)
            make.bottom.lessThanOrEqualToSuperview().inset(12)
        }
    }

    // MARK: - Configure
    func configure(date: String, title: String) {
        dateLabel.text = date
        titleLabel.text = title
    }
}

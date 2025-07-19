import UIKit
import SnapKit
import Then

class HomeView: UIView {
    // 상단 7x16 네모칸 (Git 잔디 스타일)
    let gridCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.sectionInset = .zero
        $0.setCollectionViewLayout(layout, animated: false)
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
        $0.register(GridCell.self, forCellWithReuseIdentifier: "GridCell")
        $0.showsHorizontalScrollIndicator = false
    }

    // 아래 일기 리스트 (TableView)
    let diaryTableView = UITableView(frame: .zero, style: .plain).then {
        $0.tableFooterView = UIView()
        $0.rowHeight = 70
        $0.register(DiaryCell.self, forCellReuseIdentifier: "DiaryCell")
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.separatorColor = .systemGray5
    }

    // 우하단 +버튼 (동그라미/음영/아이콘)
    public let addButton = UIButton(type: .custom).then {
        $0.backgroundColor = .systemBlue
        $0.tintColor = .white
        $0.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)), for: .normal)
        $0.layer.cornerRadius = 32
        $0.layer.masksToBounds = false
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowRadius = 6
        $0.accessibilityLabel = "일기 작성"
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .systemBackground
        addSubview(gridCollectionView)
        addSubview(diaryTableView)
        addSubview(addButton)

        gridCollectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(200)
        }
        diaryTableView.snp.makeConstraints { make in
            make.top.equalTo(gridCollectionView.snp.bottom).offset(24)
            make.left.right.bottom.equalToSuperview()
        }
        addButton.snp.makeConstraints { make in
            make.width.height.equalTo(64)
            make.right.equalToSuperview().inset(24)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(24)
        }
    }
}

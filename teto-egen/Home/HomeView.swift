import UIKit
import SnapKit
import Then

class HomeView: UIView {
    // Year selection button (yearDropdown) added at the top-left of grid area
    public let yearDropdown = UIButton(type: .system).then {
        $0.setTitle("2025", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        $0.contentHorizontalAlignment = .left
        $0.accessibilityLabel = "연도 선택"
    }
    
    // Closure to notify year selection
    public var onYearSelected: ((Int) -> Void)?
    
    // 상단 7x16 네모칸 (Git 잔디 스타일)
    let gridCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal    // changed to horizontal scroll direction
        layout.minimumInteritemSpacing = 4      // horizontal spacing between grid cells
        layout.minimumLineSpacing = 6            // vertical spacing between grid cells
        layout.sectionInset = .zero
        $0.setCollectionViewLayout(layout, animated: false)
        $0.backgroundColor = .clear
        $0.isScrollEnabled = true                // enable horizontal scrolling
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
        addSubview(yearDropdown)           // add yearDropdown to view
        addSubview(gridCollectionView)
        addSubview(diaryTableView)
        addSubview(addButton)

        yearDropdown.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().inset(16)
            make.height.equalTo(28)
            make.width.greaterThanOrEqualTo(60)
        }
        
        gridCollectionView.snp.makeConstraints { make in
            make.top.equalTo(yearDropdown.snp.bottom).offset(8)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            // Calculate cell height dynamically based on gridCollectionView height / 7 rows:
            // Set height explicitly to cellHeight * 7, cellHeight will be dynamic from width or height, so here set a fixed height for 7 rows
            // Assuming desired cellHeight, here we fix height to 7 * 16 to preserve grid cell size relative to height
            // Since scroll is horizontal, height needs to be fixed and width can scroll
            make.height.equalTo(40 * 7)  // example cellHeight of 40, total height 280 for 7 rows
        }
        
        diaryTableView.snp.makeConstraints { make in
            make.top.equalTo(gridCollectionView.snp.bottom).offset(24)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        addButton.snp.makeConstraints { make in
            make.width.height.equalTo(64)
            make.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(24)
        }
    }
}


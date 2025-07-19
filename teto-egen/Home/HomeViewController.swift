import UIKit
import RxSwift
import RxCocoa

final class HomeViewController: UIViewController {
    // MARK: - Properties
    private var viewModel = HomeViewModel()
    private let homeView = HomeView()
    private let disposeBag = DisposeBag()
    private var currentDiaryItems: [HomeViewModel.DiaryItem] = []

    // MARK: - Lifecycle
    override func loadView() {
        self.view = homeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureDelegates()
        bindActions()
        bindData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 화면이 나타날 때마다 일기 데이터 새로고침
        viewModel.loadDiaries()
    }

    // MARK: - Configuration
    private func configureNavigation() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        let today = formatter.string(from: Date())
        title = today
    }

    private func configureDelegates() {
        homeView.gridCollectionView.dataSource = self
        homeView.gridCollectionView.delegate = self
        homeView.diaryTableView.dataSource = self
        homeView.diaryTableView.delegate = self
    }

    private func bindActions() {
        homeView.addButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.openDiaryWriteViewController()
            }
            .disposed(by: disposeBag)
        
        homeView.yearDropdown.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                let alert = UIAlertController(title: "연도 선택", message: nil, preferredStyle: .actionSheet)
                
                let calendar = Calendar.current
                let currentYear = calendar.component(.year, from: Date())
                let years = (currentYear-5...currentYear).reversed()
                
                for year in years {
                    alert.addAction(UIAlertAction(title: "\(year)년", style: .default, handler: { _ in
                        self.viewModel = HomeViewModel(year: year)
                        self.homeView.gridCollectionView.reloadData()
                        self.homeView.yearDropdown.setTitle("\(year)년", for: .normal)
                    }))
                }
                
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                
                // For iPad support
                if let popover = alert.popoverPresentationController {
                    popover.sourceView = self.homeView.yearDropdown
                    popover.sourceRect = self.homeView.yearDropdown.bounds
                }
                
                self.present(alert, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindData() {
        // 일기 데이터 바인딩
        viewModel.diaryItems
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                guard let self = self else { return }
                self.currentDiaryItems = items
                self.homeView.diaryTableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func openDiaryWriteViewController() {
        let diaryWriteVC = DiaryWriteViewController()
        navigationController?.pushViewController(diaryWriteVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1 // 1섹션으로 변경
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.gridColors.count * 7 // 전체 주차 수 * 7
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as? GridCell else {
            fatalError("Failed to dequeue GridCell")
        }
        let week = indexPath.item / 7
        let weekday = indexPath.item % 7
        let type = viewModel.gridColors[week][weekday]
        cell.configure(type: type)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 7행 고정, width는 셀 높이 기준 정사각형으로 설정 (가로 스크롤 가능)
        let rows: CGFloat = 7
        let spacing: CGFloat = 6
        let totalSpacing = spacing * (rows - 1)
        let cellHeight = (collectionView.bounds.height - totalSpacing) / rows
        return CGSize(width: cellHeight, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentDiaryItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else {
            fatalError("Failed to dequeue DiaryCell")
        }
        let item = currentDiaryItems[indexPath.row]
        cell.configure(date: item.date, title: item.title)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 선택한 일기 상세보기로 이동
        let selectedDiary = currentDiaryItems[indexPath.row].diary
        openDiaryDetailViewController(diary: selectedDiary)
    }
    
    private func openDiaryDetailViewController(diary: DiaryModel) {
        // 읽기 모드로 초기화하여 일기 상세 화면 생성
        let diaryWriteVC = DiaryWriteViewController(readOnlyMode: true, diary: diary)
        navigationController?.pushViewController(diaryWriteVC, animated: true)
    }
}

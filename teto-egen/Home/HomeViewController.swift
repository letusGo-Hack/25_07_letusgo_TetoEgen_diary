import UIKit
import RxSwift
import RxCocoa

final class HomeViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = HomeViewModel()
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
        title = "메인"
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
        viewModel.gridColors.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.gridColors[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as? GridCell else {
            fatalError("Failed to dequeue GridCell")
        }
        let color = viewModel.gridColors[indexPath.section][indexPath.item]
        cell.configure(color: color)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = (15 * 2)
        let width = (collectionView.bounds.width - totalSpacing) / 16
        let height: CGFloat = 24
        return CGSize(width: width, height: height)
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

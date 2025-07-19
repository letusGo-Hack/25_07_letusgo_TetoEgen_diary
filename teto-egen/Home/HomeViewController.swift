import UIKit
import RxSwift
import RxCocoa

// Use same displayFormatter as in HomeViewModel
// (DateFormatter.displayFormatter is defined as static in HomeViewModel)

final class HomeViewController: UIViewController {
    // MARK: - Properties
    private var viewModel = HomeViewModel()
    private let homeView = HomeView()
    private let disposeBag = DisposeBag()
    private var currentDiaryItems: [Int: [HomeViewModel.DiaryItem]] = [:] // 월별
    private var currentSectionMonths: [Int] = [] // 정렬된 월
    private var currentGridColors: [[ColorType]] = []
    private var currentSelectedDate: Date?

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

    // MARK: - Bindings
    private func bindActions() {
        homeView.addButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.openDiaryWriteViewController()
            }
            .disposed(by: disposeBag)
        
        homeView.yearDropdown.rx.tap
            .bind { [weak self] in
                self?.showYearSelectionAlert()
            }
            .disposed(by: disposeBag)
    }
    
    private func bindData() {
        // 일기 데이터 바인딩
        viewModel.diaryItems
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                guard let self = self else { return }
                self.currentDiaryItems = Dictionary(grouping: items) { item in
                    guard let date = DateFormatter.displayFormatter.date(from: item.date) else { return 0 } // fallback month 0 if parse fails
                    return Calendar.current.component(.month, from: date)
                }
                self.currentSectionMonths = self.currentDiaryItems.keys.sorted()
                self.homeView.diaryTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.gridColors
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] gridColors in
                self?.currentGridColors = gridColors
                self?.homeView.gridCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.selectedDate
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] date in
                self?.currentSelectedDate = date
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Navigation
    private func openDiaryWriteViewController() {
        let diaryWriteVC = DiaryWriteViewController()
        navigationController?.pushViewController(diaryWriteVC, animated: true)
    }

    // MARK: - Detail
    private func openDiaryDetailViewController(diary: DiaryModel) {
        let diaryWriteVC = DiaryWriteViewController(readOnlyMode: true, diary: diary)
        navigationController?.pushViewController(diaryWriteVC, animated: true)
    }

    // MARK: - Year Selection
    private func showYearSelectionAlert() {
        let alert = UIAlertController(title: "연도 선택", message: nil, preferredStyle: .actionSheet)
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let years = (currentYear-5...currentYear).reversed()
        for year in years {
            alert.addAction(UIAlertAction(title: "\(year)년", style: .default, handler: { [weak self] _ in
                self?.reloadForSelectedYear(year)
            }))
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.homeView.yearDropdown
            popover.sourceRect = self.homeView.yearDropdown.bounds
        }
        self.present(alert, animated: true)
    }

    private func reloadForSelectedYear(_ year: Int) {
        self.viewModel = HomeViewModel(year: year)
        self.homeView.gridCollectionView.reloadData()
        self.homeView.yearDropdown.setTitle("\(year)년", for: .normal)
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1 // 1섹션으로 변경
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentGridColors.count * 7 // 전체 주차 수 * 7
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as? GridCell else {
            fatalError("Failed to dequeue GridCell")
        }
        let week = indexPath.item / 7
        let weekday = indexPath.item % 7
        let type = currentGridColors[week][weekday]
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

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == homeView.gridCollectionView else { return }
        let week = indexPath.item / 7
        let weekday = indexPath.item % 7
        
        let calendar = Calendar.current
        var calendarWithLocale = calendar
        calendarWithLocale.locale = Locale(identifier: "ko_KR")

        // Calculate the firstWeekStartDate as in HomeViewModel's updateGridColors
        var components = DateComponents()
        components.year = viewModel.year
        components.month = 1
        components.day = 1
        
        guard let firstDayOfYear = calendarWithLocale.date(from: components) else { return }
        
        // Find the weekday for the first day of the year
        let firstWeekday = calendarWithLocale.component(.weekday, from: firstDayOfYear) // Sunday=1
        
        // Calculate start of the first week (Sunday before or on Jan 1)
        let daysToSubtract = firstWeekday - 1
        guard let firstWeekStartDate = calendarWithLocale.date(byAdding: .day, value: -daysToSubtract, to: firstDayOfYear) else { return }
        
        // Calculate tappedDate = firstWeekStartDate + (week * 7 + weekday) days
        let daysToAdd = week * 7 + weekday
        guard let tappedDate = calendarWithLocale.date(byAdding: .day, value: daysToAdd, to: firstWeekStartDate) else { return }
        
        // Toggle selection logic
        if let selectedDate = currentSelectedDate,
           calendarWithLocale.isDate(selectedDate, inSameDayAs: tappedDate) {
            viewModel.selectDate(nil) // Show all diaries
        } else {
            viewModel.selectDate(tappedDate) // Show filtered list for tappedDate
        }
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        currentSectionMonths.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let month = currentSectionMonths[section]
        return currentDiaryItems[month]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else {
            fatalError("Failed to dequeue DiaryCell")
        }
        let month = currentSectionMonths[indexPath.section]
        let items = currentDiaryItems[month] ?? []
        let item = items[indexPath.row]
        cell.configure(date: item.date, title: item.title)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let month = currentSectionMonths[indexPath.section]
        let items = currentDiaryItems[month] ?? []
        let selectedDiary = items[indexPath.row].diary
        openDiaryDetailViewController(diary: selectedDiary)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let month = currentSectionMonths[section]
        return "\(month)월"
    }
}

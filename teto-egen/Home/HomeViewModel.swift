import UIKit
import RxSwift
import RxCocoa

class HomeViewModel {
    // 7 x 16 그리드 색상
    private let _gridColors = BehaviorRelay<[[ColorType]]>(value: [])
    var gridColors: Observable<[[ColorType]]> { _gridColors.asObservable() }

    // 일기 리스트
    private let _diaries = BehaviorRelay<[DiaryModel]>(value: [])
    var diaries: Observable<[DiaryModel]> { _diaries.asObservable() }

    // 일기 아이템 변환
    var diaryItems: Observable<[DiaryItem]> {
        diaries.map { diaries in
            diaries.map { diary in
                DiaryItem(
                    date: DateFormatter.displayFormatter.string(from: diary.date),
                    title: diary.title,
                    diary: diary
                )
            }
        }
    }

    struct DiaryItem {
        let date: String
        let title: String
        let diary: DiaryModel
    }

    let year: Int
    private let disposeBag = DisposeBag()

    init(year: Int = Calendar.current.component(.year, from: Date())) {
        self.year = year
        loadDiaries()
        setupBindings()
    }

    private func setupBindings() {
        diaries
            .subscribe(onNext: { [weak self] diaries in
                self?.updateGridColors(with: diaries)
            })
            .disposed(by: disposeBag)
    }

    private func updateGridColors(with diaries: [DiaryModel]) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1 // Sunday
        
        let startDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let endDate = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!

        let startWeekday = calendar.component(.weekday, from: startDate)
        let daysBefore = startWeekday - calendar.firstWeekday
        let adjustedDaysBefore = daysBefore >= 0 ? daysBefore : daysBefore + 7
        let firstWeekStartDate = calendar.date(byAdding: .day, value: -adjustedDaysBefore, to: startDate)!

        let endWeekday = calendar.component(.weekday, from: endDate)
        let daysAfter = 7 - (endWeekday - calendar.firstWeekday) - 1
        let adjustedDaysAfter = daysAfter >= 0 ? daysAfter : daysAfter + 7
        let lastWeekEndDate = calendar.date(byAdding: .day, value: adjustedDaysAfter, to: endDate)!

        let totalDays = calendar.dateComponents([.day], from: firstWeekStartDate, to: lastWeekEndDate).day! + 1
        let totalWeeks = totalDays / 7

        var tempGridColors: [[ColorType]] = []

        for weekIndex in 0..<totalWeeks {
            var weekColors: [ColorType] = []
            for dayIndex in 0..<7 {
                guard let currentDate = calendar.date(byAdding: .day, value: weekIndex * 7 + dayIndex, to: firstWeekStartDate) else {
                    weekColors.append(.empty)
                    continue
                }
                let currentYear = calendar.component(.year, from: currentDate)
                if currentYear != year {
                    weekColors.append(.empty)
                } else if let diary = diaries.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                    let teto = Int(diary.score.tetoScore * 100)
                    let egen = Int(diary.score.egenScore * 100)
                    let diff = teto - egen
                    let absDiff = abs(diff)
                    let grade: Int
                    if absDiff <= 33 {
                        grade = 1
                    } else if absDiff <= 66 {
                        grade = 2
                    } else {
                        grade = 3
                    }
                    if diff > 0 {
                        weekColors.append(.blue(grade))
                    } else if diff < 0 {
                        weekColors.append(.pink(grade))
                    } else {
                        weekColors.append(.empty)
                    }
                } else {
                    weekColors.append(.empty)
                }
            }
            tempGridColors.append(weekColors)
        }

        _gridColors.accept(tempGridColors)
    }

    func loadDiaries() {
        let savedDiaries = DiaryStorage.shared.loadDiaries()
        let sortedDiaries = savedDiaries.sorted { $0.date > $1.date }
        _diaries.accept(sortedDiaries)
    }
}

// 날짜 포맷터 확장
extension DateFormatter {
    static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

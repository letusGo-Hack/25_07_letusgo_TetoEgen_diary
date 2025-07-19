import UIKit
import RxSwift
import RxCocoa

class HomeViewModel {
    // 7 x 16 그리드를 위한 임의의 색상 배열 (데이터 미구현 상태)
    var gridColors: [[ColorType]] = [[]]
    
    // 일기 리스트
    private let _diaries = BehaviorRelay<[DiaryModel]>(value: [])
    var diaries: Observable<[DiaryModel]> {
        return _diaries.asObservable()
    }
    
    // 일기 아이템 변환
    var diaryItems: Observable<[DiaryItem]> {
        return diaries.map { diaries in
            return diaries.map { diary in
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

    // 년도 선택 지원을 위해 기본값 올해, 바꿀 수 있음
    let year: Int
    
    init(year: Int = Calendar.current.component(.year, from: Date())) {
        self.year = year
        
        // 저장된 일기 로드
        loadDiaries()
        
        var calendar = Calendar.current
        calendar.firstWeekday = 1 // Sunday

        // 1월 1일~12월 31일 사이 첫/마지막 일자 구함
        let startDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let endDate = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!

        // 첫 주 시작일 (해당 주의 일요일)
        let startWeekday = calendar.component(.weekday, from: startDate)
        let daysBefore = startWeekday - calendar.firstWeekday
        let adjustedDaysBefore = daysBefore >= 0 ? daysBefore : daysBefore + 7
        let firstWeekStartDate = calendar.date(byAdding: .day, value: -adjustedDaysBefore, to: startDate)!

        // 마지막 주 끝일 (해당 주의 토요일)
        let endWeekday = calendar.component(.weekday, from: endDate)
        let daysAfter = 7 - (endWeekday - calendar.firstWeekday) - 1
        let adjustedDaysAfter = daysAfter >= 0 ? daysAfter : daysAfter + 7
        let lastWeekEndDate = calendar.date(byAdding: .day, value: adjustedDaysAfter, to: endDate)!

        // 전체 일수
        let totalDays = calendar.dateComponents([.day], from: firstWeekStartDate, to: lastWeekEndDate).day! + 1

        // 총 주수
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
                } else {
                    // 일기 있는지 확인 후 색상 결정
                    if let diary = _diaries.value.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
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
            }
            tempGridColors.append(weekColors)
        }
        
        gridColors = tempGridColors
    }
    
    func loadDiaries() {
        let savedDiaries = DiaryStorage.shared.loadDiaries()
        // 날짜 순으로 정렬 (최신순)
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


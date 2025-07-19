import UIKit
import RxSwift
import RxCocoa

class HomeViewModel {
    // 7 x 16 그리드를 위한 임의의 색상 배열 (데이터 미구현 상태)
    let gridColors: [[UIColor]]
    
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

    init() {
        // 7행 16열: 랜덤 색상 진하기로 초기화
        gridColors = (0..<7).map { _ in
            (0..<16).map { _ in
                let intensity = CGFloat.random(in: 0.3...1)
                return UIColor.systemGreen.withAlphaComponent(intensity)
            }
        }
        
        // 저장된 일기 로드
        loadDiaries()
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

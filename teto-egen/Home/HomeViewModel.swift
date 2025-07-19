import UIKit

class HomeViewModel {
    // 7 x 16 그리드를 위한 임의의 색상 배열 (데이터 미구현 상태)
    let gridColors: [[UIColor]]
    // 임의의 일기 리스트 (데이터 미구현 상태)
    struct DiaryItem {
        let date: String
        let title: String
    }
    let diaryItems: [DiaryItem]

    init() {
        // 7행 16열: 랜덤 색상 진하기로 초기화
        gridColors = (0..<7).map { _ in
            (0..<16).map { _ in
                let intensity = CGFloat.random(in: 0.3...1)
                return UIColor.systemGreen.withAlphaComponent(intensity)
            }
        }
        // 임시 일기 데이터
        diaryItems = [
            DiaryItem(date: "2025-07-19", title: "오늘도 고생했다!"),
            DiaryItem(date: "2025-07-18", title: "SwiftUI 연습하기"),
            DiaryItem(date: "2025-07-17", title: "오랜만에 운동"),
            DiaryItem(date: "2025-07-16", title: "책 한권 다 읽었다"),
            DiaryItem(date: "2025-07-15", title: "맛있는 저녁"),
        ]
    }
}

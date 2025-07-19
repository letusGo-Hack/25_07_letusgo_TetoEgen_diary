//
//  DiaryStreak.swift
//  DiaryStreak
//
//  Created by 고병학 on 7/19/25.
//

import WidgetKit
import SwiftUI

// 위젯용 간단한 일기 데이터 모델
struct WidgetDiaryEntry {
    let date: Date
    let hasEntry: Bool
}

// 위젯용 데이터 로더
class WidgetDataLoader {
    static let shared = WidgetDataLoader()
    private let userDefaults = UserDefaults(suiteName: "group.com.teto-egen.diary") ?? UserDefaults.standard
    
    private init() {}
    
    func loadDiaryEntries() -> [Date] {
        guard let data = userDefaults.data(forKey: "SavedDiaries") else { return [] }
        
        do {
            let diaries = try JSONDecoder().decode([DiaryModel].self, from: data)
            return diaries.map { $0.date }
        } catch {
            print("위젯에서 일기 로드 실패: \(error)")
            return []
        }
    }
    
    func loadDiaryData() -> [DiaryModel] {
        guard let data = userDefaults.data(forKey: "SavedDiaries") else { return [] }
        
        do {
            let diaries = try JSONDecoder().decode([DiaryModel].self, from: data)
            return diaries
        } catch {
            print("위젯에서 일기 데이터 로드 실패: \(error)")
            return []
        }
    }
    
    func getLastDiaryForDate(_ date: Date) -> DiaryModel? {
        let calendar = Calendar.current
        let diaries = loadDiaryData()
        
        let sameDayDiaries = diaries.filter { calendar.isDate($0.date, inSameDayAs: date) }
        return sameDayDiaries.max(by: { $0.date < $1.date })
    }
}



struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // 현재 시간부터 시작해서 매 시간마다 업데이트
        let currentDate = Date()
        for hourOffset in 0 ..< 6 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        // 하루에 한 번씩 새로고침하도록 설정
        return Timeline(entries: entries, policy: .after(Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!))
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct DiaryStreakEntryView : View {
    var entry: Provider.Entry
    
    // 실제 일기 작성 데이터를 기반으로 한 4주간의 기록
    private var streakData: [[Bool]] {
        let calendar = Calendar.current
        let today = Date()
        let diaryDates = WidgetDataLoader.shared.loadDiaryEntries()
        var data: [[Bool]] = []
        
        for week in 0..<4 {
            var weekData: [Bool] = []
            for day in 0..<7 {
                let targetDate = calendar.date(byAdding: .day, value: -(week * 7 + day), to: today)!
                let hasEntry = diaryDates.contains { calendar.isDate($0, inSameDayAs: targetDate) }
                weekData.append(hasEntry)
            }
            data.append(weekData.reversed())
        }
        return data.reversed()
    }
    
    private var consecutiveDays: Int {
        let calendar = Calendar.current
        let today = Date()
        let diaryDates = WidgetDataLoader.shared.loadDiaryEntries()
        var streak = 0
        
        for dayOffset in 0..<30 { // 최대 30일까지 확인
            let targetDate = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let hasEntry = diaryDates.contains { calendar.isDate($0, inSameDayAs: targetDate) }
            
            if hasEntry {
                streak += 1
            } else {
                break
            }
        }
        
        return streak
    }
    
    private var totalEntries: Int {
        return WidgetDataLoader.shared.loadDiaryEntries().count
    }
    
    // 점수에 따른 색상 계산
    private func colorForScores(tetoScore: Double, egenScore: Double) -> Color {
        // 두 점수의 평균을 구해서 색상 강도 결정
        let averageScore = (tetoScore + egenScore) / 2.0
        let intensity = averageScore / 100.0
        
        // tetoScore가 더 높으면 파란색 계열, egenScore가 더 높으면 분홍색 계열
        if tetoScore > egenScore {
            return Color.blue.opacity(0.5 + intensity * 0.7)
        } else if egenScore > tetoScore {
            return Color.pink.opacity(0.5 + intensity * 0.7)
        } else {
            // 같으면 보라색 계열
            return Color.purple.opacity(0.5 + intensity * 0.7)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Spacer()
            HStack {
                Spacer()
                VStack {
                    // 헤더
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("일기 스트릭")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 8) {
                                Text("\(consecutiveDays)일 연속")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.green)
                                
                                Text("총 \(totalEntries)개")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                    
                    // 잔디 그래프
                    VStack(spacing: 4) {
                        ForEach(0..<4, id: \.self) { week in
                            HStack(spacing: 4) {
                                ForEach(0..<7, id: \.self) { day in
                                    let calendar = Calendar.current
                                    let today = Date()
                                    // 우측 하단을 오늘로, 좌측 상단을 과거로 배치
                                    // week 0 = 최근 주, week 3 = 가장 과거 주
                                    // day 0 = 일요일, day 6 = 토요일
                                    let daysFromToday = (3 - week) * 7 + (6 - day)
                                    let targetDate = calendar.date(byAdding: .day, value: -daysFromToday, to: today)!
                                    let diary = WidgetDataLoader.shared.getLastDiaryForDate(targetDate)
                                    
                                    let fillColor: Color = {
                                        if let diary = diary {
                                            return colorForScores(tetoScore: diary.score.tetoScore, egenScore: diary.score.egenScore)
                                        } else {
                                            return Color.gray.opacity(0.15)
                                        }
                                    }()
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(fillColor)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 2)
                                                .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(4)
                
                Spacer()
            }
            Spacer()
        }
        .background(Color.white)
    }
}

struct DiaryStreak: Widget {
    let kind: String = "DiaryStreak"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            DiaryStreakEntryView(entry: entry)
        }
        .contentMarginsDisabled()
        .configurationDisplayName("일기 스트릭")
        .description("일기 작성 연속 기록을 GitHub 잔디처럼 확인하세요")
        .supportedFamilies([.systemSmall])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var diary: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "�"
        return intent
    }
    
    fileprivate static var streak: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🔥"
        return intent
    }
}

#Preview(as: .systemSmall) {
    DiaryStreak()
} timeline: {
    SimpleEntry(date: .now, configuration: .diary)
    SimpleEntry(date: .now, configuration: .streak)
}


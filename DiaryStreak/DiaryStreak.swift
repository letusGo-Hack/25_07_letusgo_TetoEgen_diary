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
}

// 위젯용 간단한 일기 모델 (메인 앱의 DiaryModel과 호환)
struct SimpleDiary: Codable {
    let title: String
    let contents: String
    let date: Date
    let score: SimpleScore
    
    struct SimpleScore: Codable {
        let tetoScore: Double
        let tetoDescription: String
        let egenScore: Double
        let egenDescription: String
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

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
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
                
                // 테토/에겐 표시
                HStack(spacing: 3) {
                    Text("테")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 12, height: 12)
                        .background(Circle().fill(Color.blue))
                    
                    Text("에")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 12, height: 12)
                        .background(Circle().fill(Color.pink))
                }
            }
            
            // 잔디 그래프
            VStack(spacing: 2) {
                ForEach(0..<4, id: \.self) { week in
                    HStack(spacing: 2) {
                        ForEach(0..<7, id: \.self) { day in
                            let hasEntry = streakData[week][day]
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(hasEntry ? Color.green.opacity(0.8) : Color.gray.opacity(0.15))
                                .frame(width: 11, height: 11)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
                                )
                        }
                    }
                }
            }
            
            // 범례 및 요일 표시
            HStack {
                Text("월")
                    .font(.system(size: 7))
                    .foregroundColor(.secondary)
                    .frame(width: 11)
                
                Spacer()
                
                Text("수")
                    .font(.system(size: 7))
                    .foregroundColor(.secondary)
                    .frame(width: 11)
                
                Spacer()
                
                Text("금")
                    .font(.system(size: 7))
                    .foregroundColor(.secondary)
                    .frame(width: 11)
                
                Spacer()
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
    }
}

struct DiaryStreak: Widget {
    let kind: String = "DiaryStreak"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            DiaryStreakEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
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

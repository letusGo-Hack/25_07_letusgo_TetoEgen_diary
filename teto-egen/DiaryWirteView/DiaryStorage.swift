//
//  DiaryStorage.swift
//  teto-egen
//
//  Created by 고병학 on 7/19/25.
//

import Foundation

class DiaryStorage {
    static let shared = DiaryStorage()
    private let userDefaults = UserDefaults(suiteName: "group.com.teto-egen.diary") ?? UserDefaults.standard
    private let diariesKey = "SavedDiaries"
    
    private init() {}
    
    func saveDiary(_ diary: DiaryModel) {
        var savedDiaries = loadDiaries()
        savedDiaries.append(diary)
        
        do {
            let data = try JSONEncoder().encode(savedDiaries)
            userDefaults.set(data, forKey: diariesKey)
            userDefaults.synchronize()
        } catch {
            print("일기 저장 실패: \(error)")
        }
    }
    
    func loadDiaries() -> [DiaryModel] {
        guard let data = userDefaults.data(forKey: diariesKey) else {
            return []
        }
        
        do {
            let diaries = try JSONDecoder().decode([DiaryModel].self, from: data)
            return diaries
        } catch {
            print("일기 로드 실패: \(error)")
            return []
        }
    }
    
    func deleteDiary(at index: Int) {
        var savedDiaries = loadDiaries()
        guard index < savedDiaries.count else { return }
        
        savedDiaries.remove(at: index)
        
        do {
            let data = try JSONEncoder().encode(savedDiaries)
            userDefaults.set(data, forKey: diariesKey)
            userDefaults.synchronize()
        } catch {
            print("일기 삭제 실패: \(error)")
        }
    }
    
    func deleteDiary(_ diary: DiaryModel) {
        var savedDiaries = loadDiaries()
        
        // 날짜와 제목으로 일기 찾기 (고유 식별자 역할)
        if let index = savedDiaries.firstIndex(where: { $0.date == diary.date && $0.title == diary.title }) {
            savedDiaries.remove(at: index)
            
            do {
                let data = try JSONEncoder().encode(savedDiaries)
                userDefaults.set(data, forKey: diariesKey)
                userDefaults.synchronize()
                print("일기 삭제 성공")
            } catch {
                print("일기 삭제 실패: \(error)")
            }
        } else {
            print("삭제할 일기를 찾을 수 없습니다.")
        }
    }
}

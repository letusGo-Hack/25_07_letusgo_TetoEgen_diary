//
//  DiaryStorage.swift
//  teto-egen
//
//  Created by 고병학 on 7/19/25.
//

import Foundation

class DiaryStorage {
    static let shared = DiaryStorage()
    private let userDefaults = UserDefaults.standard
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
}

//
//  File.swift
//  teto-egen
//
//  Created by 고병학 on 7/19/25.
//

import Foundation

extension DateFormatter {
    static let koreanDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter
    }()
}

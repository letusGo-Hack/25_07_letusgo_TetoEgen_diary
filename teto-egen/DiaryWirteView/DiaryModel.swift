//
//  DiaryModel.swift
//  teto-egen
//
//  Created by 고병학 on 7/19/25.
//

import Foundation

struct DiaryModel: Codable {
    var title: String
    var contents: String
    var score: DiaryScoreModel
    var image: Data?
    var date: Date
}

//
//  ShareTypeModel.swift
//  teto-egen
//
//  Created by 서문가은 on 7/19/25.
//


enum ShareTypeModel {
    case teto(ShareLevelModel)
    case egen(ShareLevelModel)

    init(from model: DiaryScoreModel) {
        let diff = abs(model.tetoScore - model.egenScore)
        let level = ShareLevelModel(diff: Int(diff))
        
        if model.tetoScore >= model.egenScore {
            self = .teto(level)
        } else {
            self = .egen(level)
        }
    }
    
    var title: String {
        switch self {
        case .teto: return "🧊테토"
        case .egen: return "🔥에겐"
        }
    }

    var description: String {
        switch self {
        case .teto(.one): return "세상과 거리두는 중인"
        case .teto(.two): return "감정보다 팩트가 중요한"
        case .teto(.three): return "감정 표현 0%, 이성 100%"
        case .egen(.one): return "감정 요동치는"
        case .egen(.two): return "한 줄 일기에도 감정선이 흐르는"
        case .egen(.three): return "오늘 하루도 마음이 먼저 반응한"
        }
    }
}

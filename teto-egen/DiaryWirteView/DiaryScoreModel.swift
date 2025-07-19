//
//  DiaryScoreModel.swift
//  teto-egen
//
//  Created by 고병학 on 7/19/25.
//

import Foundation
import FoundationModels

@Generable
struct DiaryScoreModel: Equatable, Codable {
    
    @Guide(description: "테토력(강인함, 리더십, 추진력, 독립성). 값의 범위는 0에서 1사이의 실수이고, 소수점 4자리까지 측정해줘. 예) 0.4288")
    let tetoScore: Double
    
    @Guide(description: "테스토스테론 점수가 나온 근거 (최대 100자)")
    let tetoDescription: String
    
    @Guide(description: "에겐력(감성, 공감, 배려, 부드러움). 값의 범위는 0에서 1사이의 실수이고, 소수점 4자리까지 측정해줘. 예) 0.4288")
    let egenScore: Double
    
    @Guide(description: "에스트로겐 점수가 나온 근거 (최대 100자)")
    let egenDescription: String
    
}

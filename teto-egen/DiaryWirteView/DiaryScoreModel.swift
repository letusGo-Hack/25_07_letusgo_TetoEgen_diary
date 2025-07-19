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
    
    @Guide(description: "테토력 점수. 값의 범위는 0에서 100사이의 실수이고, 소수점 2자리까지 측정해줘. 예) 42.88")
    let tetoScore: Double
    
    @Guide(description: "테스토스테론 점수가 나온 근거. 재밌게 작성해줘. (최대 100자)")
    let tetoDescription: String
    
    @Guide(description: "에겐력 점수. 값의 범위는 0에서 100사이의 실수이고, 소수점 2자리까지 측정해줘. 예) 42.88")
    let egenScore: Double
    
    @Guide(description: "에스트로겐 점수가 나온 근거. 재밌게 작성해줘. (최대 100자)")
    let egenDescription: String
    
}

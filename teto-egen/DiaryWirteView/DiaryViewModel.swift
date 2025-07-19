//
//  DiaryViewModel.swift
//  teto-egen
//
//  Created by 고병학 on 7/19/25.
//

import Foundation
import RxSwift
import FoundationModels

class DiaryViewModel {
    let analysisResult = PublishSubject<DiaryScoreModel>()
    
    func analyzeDiary(text: String, title: String, date: Date) {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            
            do {
                let systemPrompt = """
                당신은 일기 감별사야.
                다음 일기 내용을 분석해서 테토력과 에겐력을 측정해.
                
                <측정기준>
                <테토력>
                테토력(강인함, 리더십, 추진력)을 0에서 1사이의 실수면서 소수점 4자리까지 측정해줘.
                테토력은 테스토스테론(남성호르몬) 기반의 특성을 상징하는 밈 용어로, 주로 강인하고 주도적인 성향을 나타내요. 구체적으로는 리더십이 강하고, 도전적인 상황에서 앞장서며, 추진력과 독립성이 돋보이는 면을 강조합니다. 예를 들어, 헬스장에서 무거운 웨이트를 들거나, 프로젝트를 이끌며 목표를 달성하는 행동이 테토력이 높다고 볼 수 있어요. 밈에서는 '테토남'이나 '테토녀'로 표현되며, 터프한 이미지(문신, 근육질 스타일)나 '상남자/상여자' 같은 매력을 더하죠. 연애 측면에서는 에겐녀(감성적인 타입)를 끌어당기는 '보호자' 역할로 자주 묘사되지만, 과도하면 가부장적이나 공격적으로 비칠 수 있어요. 이는 재미로 즐기는 분류지만, 실제 호르몬 수치와 무관한 주관적 평가예요!
                </테토력>
                
                <에겐력>
                에겐력(감성, 공감, 배려)을 0에서 1사이의 실수면서 소수점 4자리까지 측정해줘.
                에겐력은 에스트로겐(여성호르몬) 기반으로 한 특성을 뜻하며, 주로 부드럽고 감성적인 면을 강조해요. 예를 들어, 친구의 고민을 공감하며 위로해주는 행동, 로맨틱한 분위기를 즐기거나 꽃 같은 작은 선물을 좋아하는 스타일이 강할수록 에겐력이 높아요. 밈에서는 '섬세한 에겐남/에겐녀'로 묘사되며, 감정 표현이 풍부하고 배려심이 깊어 관계에서 안정감을 주는 타입으로 보이죠. 반대로 낮으면 더 직설적이고 덜 감정적인 면이 드러날 수 있어요!
                </에겐력>
                </측정기준>
                """
                let session = LanguageModelSession(instructions: systemPrompt)
                
                // 2) 토큰 샘플링 옵션 설정
                let options = GenerationOptions(
                    temperature: 0.7,
                    maximumResponseTokens: 300
                )
                
                // 3) 프롬프트 생성 & 응답 요청
                let userPrompt = """
                       아래 일기에서 테토력, 에겐력을 측정해줘.:\n\"\"\"\n\(text)\n\"\"\"
                       """
                let analysis = try await session.respond(
                    to: userPrompt,
                    generating: DiaryScoreModel.self,
                    options: options
                )
                let analysisModel = analysis.content
                
                // 4) 결과 전달 (메인 스레드 보장)
                await MainActor.run {
                    let result = DiaryScoreModel(
                        tetoScore: analysisModel.tetoScore,
                        tetoDescription: analysisModel.tetoDescription,
                        egenScore: analysisModel.egenScore,
                        egenDescription: analysisModel.egenDescription
                    )
                    dump(result)
                    self.analysisResult.onNext(result)
                }
            } catch {
                // FoundationModels.GenerationError 등 모든 오류를 문자열로 전달
                await MainActor.run {
                    let errorResult = DiaryScoreModel(
                        tetoScore: 0.0,
                        tetoDescription: "분석 실패: \(error.localizedDescription)",
                        egenScore: 0.0,
                        egenDescription: "분석 실패: \(error.localizedDescription)"
                    )
                    self.analysisResult.onNext(errorResult)
                }
            }
        }
    }
}

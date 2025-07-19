//
//  DiaryWriteViewController.swift
//  teto-egen
//
//  Created by 고병학 on 7/19/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import FoundationModels

class DiaryWriteViewController: UIViewController {
    
    // UI 컴포넌트
    private let titleLabel = UILabel().then {
        $0.text = "오늘의 일기 작성"
        $0.font = UIFont.boldSystemFont(ofSize: 24)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    private let diaryTextView = UITextView().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .darkGray
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = 8
        $0.isEditable = true
        $0.isScrollEnabled = true
    }
    
    private let submitButton = UIButton(type: .system).then {
        $0.setTitle("작성", for: .normal)
        $0.backgroundColor = .blue
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 8
    }
    
    private let resultLabel = UILabel().then {
        $0.text = "측정 결과: "
        $0.font = UIFont.systemFont(ofSize: 18)
        $0.textColor = .black
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private let summaryLabel = UILabel().then {
        $0.text = "요약: "
        $0.font = UIFont.systemFont(ofSize: 18)
        $0.textColor = .black
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    // RxSwift DisposeBag
    private let disposeBag = DisposeBag()
    
    // ViewModel (간단한 예시로, 실제 AI 분석 로직은 별도 구현 필요)
    private let viewModel = DiaryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        bindRx()
    }
    
    private func setupUI() {
        // SnapKit을 사용한 레이아웃 설정
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        view.addSubview(diaryTextView)
        diaryTextView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(diaryTextView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        view.addSubview(resultLabel)
        resultLabel.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        view.addSubview(summaryLabel)
        summaryLabel.snp.makeConstraints { make in
            make.top.equalTo(resultLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
    }
    
    private func bindRx() {
        // 제출 버튼 탭 이벤트 바인딩
        submitButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self, let text = self.diaryTextView.text else { return }
                self.viewModel.analyzeDiary(text: text)
                self.viewModel.summarizeDiary(text: text)
            })
            .disposed(by: disposeBag)
        
        // ViewModel의 결과 Observable 바인딩
        viewModel.analysisResult
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                self?.resultLabel.text = "측정 결과: 테토력 \(result.teto)% / 에겐력 \(result.egen)%"
            })
            .disposed(by: disposeBag)
        
        viewModel.summaryResult
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] summary in
                self?.summaryLabel.text = "요약: \(summary)"
            })
            .disposed(by: disposeBag)
        
        // 텍스트뷰 변화 감지 (예: 글자 수 제한 등 추가 가능)
        diaryTextView.rx.text
            .orEmpty
            .map { $0.count > 0 }
            .bind(to: submitButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

// ViewModel 클래스 (예시: 실제 AI 분석은 NLP 라이브러리나 API 연동 필요)
class DiaryViewModel {
    let analysisResult = PublishSubject<(teto: Int, egen: Int)>()
    let summaryResult = PublishSubject<String>()
    
    func analyzeDiary(text: String) {
        // 간단한 모의 분석 로직 (실제로는 AI 모델 사용)
        let teto = Int.random(in: 0...100)  // 테토력 모의
        let egen = 100 - teto  // 에겐력 모의 (합 100으로 가정)
        analysisResult.onNext((teto: teto, egen: egen))
    }
    
    func summarizeDiary(text: String) {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            
            do {
                // 1) 세션 준비(지속적인 대화가 아니라면 매번 새로 만들어도 무방)
                let systemPrompt = """
                       당신은 개인 일기를 친근한 한국어로 간결하게 요약해 주는 비서입니다.
                       · 핵심 사건과 감정만 뽑아 3문장 이하로 정리하세요.
                       · “오늘은 …했다.” 같은 1인칭 현재·과거형 표현을 사용하세요.
                       """
                let session = LanguageModelSession(instructions: systemPrompt)
                
                // 2) 토큰 샘플링 옵션 설정
                let options = GenerationOptions(
                    temperature: 0.3,          // 안정적인 요약을 위해 낮은 값
                    maximumResponseTokens: 64 // 128토큰이면 한글 300자 내외
                )
                
                // 3) 프롬프트 생성 & 응답 요청
                let userPrompt = """
                       아래 일기를 요약해 줘:\n\"\"\"\n\(text)\n\"\"\"
                       """
                let summary = try await session.respond(
                    to: userPrompt,
                    options: options
                )
                let summaryText = summary.content
                
                // 4) 결과 전달 (메인 스레드 보장)
                await MainActor.run {
                    self.summaryResult.onNext(summaryText)
                }
            } catch {
                // FoundationModels.GenerationError 등 모든 오류를 문자열로 전달
                await MainActor.run {
                    self.summaryResult.onNext("요약 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}


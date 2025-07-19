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
    private let dateButton = UIButton(type: .system).then {
        $0.setTitle(DateFormatter.koreanDateFormatter.string(from: Date()), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        $0.setTitleColor(.blue, for: .normal)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = 8
        $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        $0.isHidden = true
    }
    
    private let datePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .compact
        $0.maximumDate = Date()
        $0.date = Date()
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
    
    private let characterCountLabel = UILabel().then {
        $0.text = "0 / 200"
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .gray
        $0.textAlignment = .right
    }
    
    private let analysisLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 18)
        $0.textColor = .black
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    // 테토력 차트 컨테이너
    private let tetoChartContainer = UIView().then {
        $0.isHidden = true
    }
    
    private let tetoLabel = UILabel().then {
        $0.text = "테토력"
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    private let tetoScoreLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .gray
        $0.textAlignment = .right
    }
    
    private let tetoProgressBar = UIProgressView(progressViewStyle: .default).then {
        $0.progressTintColor = UIColor.systemBlue
        $0.trackTintColor = UIColor.lightGray
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
    }
    
    private let tetoDescriptionLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = .darkGray
        $0.numberOfLines = 0
    }
    
    // 에겐력 차트 컨테이너
    private let egenChartContainer = UIView().then {
        $0.isHidden = true
    }
    
    private let egenLabel = UILabel().then {
        $0.text = "에겐력"
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    private let egenScoreLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .gray
        $0.textAlignment = .right
    }
    
    private let egenProgressBar = UIProgressView(progressViewStyle: .default).then {
        $0.progressTintColor = UIColor.systemPink
        $0.trackTintColor = UIColor.lightGray
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
    }
    
    private let egenDescriptionLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = .darkGray
        $0.numberOfLines = 0
    }
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large).then {
        $0.color = .white
        $0.hidesWhenStopped = true
    }
    
    private let dimBackgroundView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        $0.isHidden = true
    }
    
    // RxSwift DisposeBag
    private let disposeBag = DisposeBag()
    
    // 선택된 날짜
    private var selectedDate = Date()
    
    // ViewModel (간단한 예시로, 실제 AI 분석 로직은 별도 구현 필요)
    private let viewModel = DiaryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        bindRx()
    }
    
    private func setupUI() {
        // 네비게이션 바 설정
        setupNavigationBar()
        
        // SnapKit을 사용한 레이아웃 설정
        view.addSubview(dateButton)
        dateButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)
        }
        
        view.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(diaryTextView)
        diaryTextView.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        view.addSubview(characterCountLabel)
        characterCountLabel.snp.makeConstraints { make in
            make.top.equalTo(diaryTextView.snp.bottom).offset(5)
            make.right.equalToSuperview().inset(20)
        }
        
        view.addSubview(analysisLabel)
        analysisLabel.snp.makeConstraints { make in
            make.top.equalTo(characterCountLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        setupChartContainers()
        
        view.addSubview(dimBackgroundView)
        dimBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        dimBackgroundView.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupChartContainers() {
        // 테토력 차트 설정
        view.addSubview(tetoChartContainer)
        tetoChartContainer.snp.makeConstraints { make in
            make.top.equalTo(analysisLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        tetoChartContainer.addSubview(tetoLabel)
        tetoLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }
        
        tetoChartContainer.addSubview(tetoScoreLabel)
        tetoScoreLabel.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.left.greaterThanOrEqualTo(tetoLabel.snp.right).offset(8)
        }
        
        tetoChartContainer.addSubview(tetoProgressBar)
        tetoProgressBar.snp.makeConstraints { make in
            make.top.equalTo(tetoLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(8)
        }
        
        tetoChartContainer.addSubview(tetoDescriptionLabel)
        tetoDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(tetoProgressBar.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
        
        // 에겐력 차트 설정
        view.addSubview(egenChartContainer)
        egenChartContainer.snp.makeConstraints { make in
            make.top.equalTo(tetoChartContainer.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        egenChartContainer.addSubview(egenLabel)
        egenLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }
        
        egenChartContainer.addSubview(egenScoreLabel)
        egenScoreLabel.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.left.greaterThanOrEqualTo(egenLabel.snp.right).offset(8)
        }
        
        egenChartContainer.addSubview(egenProgressBar)
        egenProgressBar.snp.makeConstraints { make in
            make.top.equalTo(egenLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(8)
        }
        
        egenChartContainer.addSubview(egenDescriptionLabel)
        egenDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(egenProgressBar.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        // 네비게이션 바 타이틀 설정
        self.title = "일기 작성"
        
        // 네비게이션 바 우측에 작성 버튼 추가
        let submitBarButton = UIBarButtonItem(
            title: "작성",
            style: .prominent,
            target: nil,
            action: nil
        )
        navigationItem.rightBarButtonItem = submitBarButton
    }
    
    private func bindRx() {
        // 날짜 피커 값 변경 이벤트
        datePicker.rx.date
            .subscribe(onNext: { [weak self] date in
                self?.selectedDate = date
            })
            .disposed(by: disposeBag)
        
        // 네비게이션 바 작성 버튼 탭 이벤트 바인딩
        guard let submitBarButton = navigationItem.rightBarButtonItem else { return }
        
        submitBarButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self, let text = self.diaryTextView.text else { return }
                self.showLoading()
                self.viewModel.analyzeDiary(text: text)
            })
            .disposed(by: disposeBag)
        
        viewModel.analysisResult
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] analysis in
                self?.hideLoading()
                self?.updateChartWithAnalysis(analysis)
            })
            .disposed(by: disposeBag)
        
        // 텍스트뷰 변화 감지 및 글자 수 제한 (100자)
        diaryTextView.rx.text
            .orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                
                // 100자 초과 시 자르기
                if text.count > 200 {
                    let index = text.index(text.startIndex, offsetBy: 200)
                    let trimmedText = String(text[..<index])
                    self.diaryTextView.text = trimmedText
                    self.characterCountLabel.text = "200 / 200"
                } else {
                    // 글자 수 표시 업데이트
                    self.characterCountLabel.text = "\(text.count) / 200"
                }
                
                // 글자 수에 따른 색상 변경 (90자 이상이면 빨간색)
                if text.count >= 90 {
                    self.characterCountLabel.textColor = .red
                } else {
                    self.characterCountLabel.textColor = .gray
                }
            })
            .disposed(by: disposeBag)
        
        // 네비게이션 바 버튼 활성화 조건
        diaryTextView.rx.text
            .orEmpty
            .map { $0.count > 0 }
            .subscribe(onNext: { [weak self] hasText in
                self?.navigationItem.rightBarButtonItem?.isEnabled = hasText
            })
            .disposed(by: disposeBag)
    }
    
    private func showLoading() {
        analysisLabel.text = ""
        tetoChartContainer.isHidden = true
        egenChartContainer.isHidden = true
        dimBackgroundView.isHidden = false
        loadingIndicator.startAnimating()
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func hideLoading() {
        dimBackgroundView.isHidden = true
        loadingIndicator.stopAnimating()
        navigationItem.rightBarButtonItem?.isEnabled = !diaryTextView.text.isEmpty
    }
    
    private func updateChartWithAnalysis(_ analysisResult: DiaryAnalysisResult) {
        analysisLabel.text = "분석 완료!"
        
        // 테토력 차트 업데이트
        tetoScoreLabel.text = String(format: "%.2f", analysisResult.tetoScore * 100)
        tetoProgressBar.setProgress(Float(analysisResult.tetoScore), animated: true)
        tetoDescriptionLabel.text = analysisResult.tetoDescription
        tetoChartContainer.isHidden = false
        
        // 에겐력 차트 업데이트
        egenScoreLabel.text = String(format: "%.2f", analysisResult.egenScore * 100)
        egenProgressBar.setProgress(Float(analysisResult.egenScore), animated: true)
        egenDescriptionLabel.text = analysisResult.egenDescription
        egenChartContainer.isHidden = false
    }
}

// 분석 결과 구조체
struct DiaryAnalysisResult {
    let tetoScore: Double
    let tetoDescription: String
    let egenScore: Double
    let egenDescription: String
}

// 날짜 포맷터 확장
extension DateFormatter {
    static let koreanDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter
    }()
}

// ViewModel 클래스 (예시: 실제 AI 분석은 NLP 라이브러리나 API 연동 필요)
class DiaryViewModel {
    let analysisResult = PublishSubject<DiaryAnalysisResult>()
    
    func analyzeDiary(text: String) {
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
                    let result = DiaryAnalysisResult(
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
                    let errorResult = DiaryAnalysisResult(
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


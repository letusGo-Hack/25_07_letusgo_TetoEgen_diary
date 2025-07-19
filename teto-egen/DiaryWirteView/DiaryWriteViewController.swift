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
    
    private let dateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .darkGray
        $0.textAlignment = .center
        $0.backgroundColor = UIColor.systemGray6
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    
    private let titleTextField = UITextField().then {
        $0.placeholder = "일기 제목을 입력하세요"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.borderStyle = .roundedRect
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = 8
        $0.clearButtonMode = .whileEditing
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 18)
        $0.textColor = .black
        $0.numberOfLines = 0
        $0.isHidden = true
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
    
    private let contentsLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .darkGray
        $0.numberOfLines = 0
        $0.isHidden = true
    }
    
    private let characterCountLabel = UILabel().then {
        $0.text = "0 / 200"
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .gray
        $0.textAlignment = .right
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
    
    // 읽기 모드 설정
    private var isReadOnlyMode: Bool = false
    private var existingDiary: DiaryModel?
    
    // ViewModel (간단한 예시로, 실제 AI 분석 로직은 별도 구현 필요)
    private let viewModel = DiaryViewModel()
    
    // MARK: - Initializers
    init(readOnlyMode: Bool = false, diary: DiaryModel? = nil) {
        self.isReadOnlyMode = readOnlyMode
        self.existingDiary = diary
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        bindRx()
        
        // 읽기 모드인 경우 기존 일기 데이터로 설정
        if isReadOnlyMode, let diary = existingDiary {
            setupWithExistingDiary(diary)
        }
    }
    
    // 기존 일기를 읽기 모드로 설정하는 메서드
    func setupWithExistingDiary(_ diary: DiaryModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 날짜 설정
            self.selectedDate = diary.date
            self.datePicker.date = diary.date
            
            // 제목과 내용 설정 후 읽기 모드로 전환
            self.switchToReadOnlyMode(title: diary.title, contents: diary.contents)
            
            // 분석 결과 표시
            self.updateChartWithAnalysis(diary.score)
        }
    }
    
    private func setupUI() {
        // 네비게이션 바 설정
        updateNavigationBar()
        
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
        
        view.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)
            make.width.equalTo(200)
        }
        
        view.addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        view.addSubview(diaryTextView)
        diaryTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        view.addSubview(contentsLabel)
        contentsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        view.addSubview(characterCountLabel)
        characterCountLabel.snp.makeConstraints { make in
            make.top.equalTo(diaryTextView.snp.bottom).offset(5)
            make.right.equalToSuperview().inset(20)
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
            make.top.equalTo(characterCountLabel.snp.bottom).offset(20)
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
    
    private func updateNavigationBar() {
        // 읽기 모드에 따른 네비게이션 바 설정
        if isReadOnlyMode {
            self.title = "일기"
            // 읽기 모드에서는 삭제 버튼 추가
            let deleteBarButton = UIBarButtonItem(
                title: "삭제",
                style: .plain,
                target: nil,
                action: nil
            )
            deleteBarButton.tintColor = .systemRed
            navigationItem.rightBarButtonItem = deleteBarButton
            
            // 삭제 버튼 바인딩
            deleteBarButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.showDeleteConfirmationAlert()
                })
                .disposed(by: disposeBag)
        } else {
            self.title = "일기 작성"
            // 네비게이션 바 우측에 저장 버튼 추가
            let submitBarButton = UIBarButtonItem(
                title: "저장",
                style: .prominent,
                target: nil,
                action: nil
            )
            navigationItem.rightBarButtonItem = submitBarButton
            
            // 저장 버튼 바인딩
            submitBarButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    guard let self = self,
                          let text = self.diaryTextView.text,
                          let title = self.titleTextField.text,
                          !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    self.view.endEditing(true)
                    self.showLoading()
                    self.viewModel.analyzeDiary(text: text, title: title, date: self.selectedDate)
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func bindRx() {
        // 날짜 피커 값 변경 이벤트
        datePicker.rx.date
            .subscribe(onNext: { [weak self] date in
                self?.selectedDate = date
            })
            .disposed(by: disposeBag)
        
        viewModel.analysisResult
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] analysis in
                self?.hideLoading()
                self?.updateChartWithAnalysis(analysis)
                self?.saveDiary(analysis)
            })
            .disposed(by: disposeBag)
        
        // 분석 실패 처리
        viewModel.analysisError
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                self?.hideLoading()
                self?.showAnalysisFailureAlert(message: errorMessage)
            })
            .disposed(by: disposeBag)
        
        // 읽기 모드가 아닐 때만 텍스트 입력 관련 바인딩
        if !isReadOnlyMode {
            bindTextInputs()
        }
    }
    
    private func bindTextInputs() {
        // 텍스트뷰 변화 감지 및 글자 수 제한 (200자)
        diaryTextView.rx.text
            .orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                
                // 200자 초과 시 자르기
                if text.count > 200 {
                    let index = text.index(text.startIndex, offsetBy: 200)
                    let trimmedText = String(text[..<index])
                    self.diaryTextView.text = trimmedText
                    self.characterCountLabel.text = "200 / 200"
                } else {
                    // 글자 수 표시 업데이트
                    self.characterCountLabel.text = "\(text.count) / 200"
                }
                
                // 글자 수에 따른 색상 변경 (180자 이상이면 빨간색)
                if text.count >= 180 {
                    self.characterCountLabel.textColor = .red
                } else {
                    self.characterCountLabel.textColor = .gray
                }
            })
            .disposed(by: disposeBag)
        
        // 네비게이션 바 버튼 활성화 조건
        Observable.combineLatest(
            titleTextField.rx.text.orEmpty.map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            diaryTextView.rx.text.orEmpty.map { $0.count > 0 }
        )
        .map { titleHasText, contentHasText in
            return titleHasText && contentHasText
        }
        .subscribe(onNext: { [weak self] isValid in
            self?.navigationItem.rightBarButtonItem?.isEnabled = isValid
        })
        .disposed(by: disposeBag)
    }
    
    private func showLoading() {
        tetoChartContainer.isHidden = true
        egenChartContainer.isHidden = true
        dimBackgroundView.isHidden = false
        loadingIndicator.startAnimating()
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func hideLoading() {
        dimBackgroundView.isHidden = true
        loadingIndicator.stopAnimating()
        
        // 제목과 내용이 모두 있을 때만 버튼 활성화
        let titleHasText = !(titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let contentHasText = !diaryTextView.text.isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = titleHasText && contentHasText
    }
    
    private func updateChartWithAnalysis(_ analysisResult: DiaryScoreModel) {
        // 테토력 차트 업데이트
        tetoScoreLabel.text = String(format: "%.2f", analysisResult.tetoScore)
        tetoProgressBar.setProgress(Float(analysisResult.tetoScore / 100), animated: true)
        tetoDescriptionLabel.text = analysisResult.tetoDescription
        tetoChartContainer.isHidden = false
        
        // 에겐력 차트 업데이트
        egenScoreLabel.text = String(format: "%.2f", analysisResult.egenScore)
        egenProgressBar.setProgress(Float(analysisResult.egenScore / 100), animated: true)
        egenDescriptionLabel.text = analysisResult.egenDescription
        egenChartContainer.isHidden = false
    }
    
    private func saveDiary(_ analysisResult: DiaryScoreModel) {
        guard let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty,
              let contents = diaryTextView.text,
              !contents.isEmpty else {
            return
        }
        
        let diary = DiaryModel(
            title: title,
            contents: contents,
            score: analysisResult,
            image: nil,
            date: selectedDate
        )
        
        // UserDefaults에 저장
        DiaryStorage.shared.saveDiary(diary)
        
        // UI를 읽기 전용으로 변경
        switchToReadOnlyMode(title: title, contents: contents)
        
        // 저장 완료 알림
        showSaveSuccessAlert()
    }
    
    private func switchToReadOnlyMode(title: String, contents: String) {
        // 읽기 모드로 전환
        isReadOnlyMode = true
        
        // 입력 필드 숨기기
        titleTextField.isHidden = true
        diaryTextView.isHidden = true
        characterCountLabel.isHidden = true
        
        // 날짜 피커 숨기고 날짜 라벨 표시
        datePicker.isHidden = true
        dateLabel.text = DateFormatter.koreanDateFormatter.string(from: selectedDate)
        dateLabel.isHidden = false
        
        // 읽기 전용 라벨 표시
        titleLabel.text = title
        titleLabel.isHidden = false
        
        contentsLabel.text = contents
        contentsLabel.isHidden = false
        
        // 테토력 차트 제약조건 업데이트 (읽기 모드에서)
        tetoChartContainer.snp.remakeConstraints { make in
            make.top.equalTo(contentsLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // 네비게이션 바 업데이트
        updateNavigationBar()
    }
    
    private func showSaveSuccessAlert() {
        let alert = UIAlertController(
            title: "저장 완료",
            message: "일기가 성공적으로 저장되었습니다.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "확인", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func showAnalysisFailureAlert(message: String) {
        let alert = UIAlertController(
            title: "분석 실패",
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "다시 작성", style: .default) { [weak self] _ in
            // 사용자가 다시 작성할 수 있도록 UI 상태 복원
            self?.resetForRetry()
        }
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func resetForRetry() {
        // 저장 버튼 다시 활성화 (제목과 내용이 있는 경우)
        let titleHasText = !(titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let contentHasText = !diaryTextView.text.isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = titleHasText && contentHasText
    }
    
    private func showDeleteConfirmationAlert() {
        let alert = UIAlertController(
            title: "일기 삭제",
            message: "이 일기를 삭제하시겠습니까?\n삭제된 일기는 복구할 수 없습니다.",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.deleteDiary()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }
    
    private func deleteDiary() {
        guard let diary = existingDiary else { return }
        
        // DiaryStorage에서 일기 삭제
        DiaryStorage.shared.deleteDiary(diary)
        
        // 삭제 성공 알럿 표시 후 뒤로 가기
        showDeleteSuccessAlert()
    }
    
    private func showDeleteSuccessAlert() {
        let alert = UIAlertController(
            title: "삭제 완료",
            message: "일기가 성공적으로 삭제되었습니다.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            // 홈 화면으로 돌아가기
            self?.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

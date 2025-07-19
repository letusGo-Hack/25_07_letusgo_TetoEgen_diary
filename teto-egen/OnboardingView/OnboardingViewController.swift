//
//  OnboardingViewController.swift
//  teto-egen
//
//  Created by 서문가은 on 7/19/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class OnboardingViewController: UIViewController {
    
    private let onboardingView = OnboardingView()
    private let onboardingViewModel = OnboardingViewModel()
    
    private let disposeBag = DisposeBag()
   
    override func loadView() {
        view = onboardingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
}

extension OnboardingViewController {
    
    private func bind() {
        let nickname = onboardingView.nicknameTextField.rx.text.orEmpty.asObservable()
        let gender = onboardingView.genderSegmentedControl.rx.selectedSegmentIndex.asObservable()
        let completeButtonTapped = onboardingView.completeButton.rx.tap.asObservable()
        let input = OnboardingViewModel.Input(
            nickname: nickname,
            gender: gender,
            completeButtonTapped: completeButtonTapped
        )
        let output = onboardingViewModel.transform(input: input)
        
        output.availableCompleteButton
            .drive(onboardingView.completeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        output.complete
            .drive(with: self, onNext: { owner, _ in
                owner.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

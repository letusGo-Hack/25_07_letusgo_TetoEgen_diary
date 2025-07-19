//
//  OnboardingViewModel.swift
//  teto-egen
//
//  Created by 서문가은 on 7/19/25.
//

import RxSwift
import RxRelay
import RxCocoa

class OnboardingViewModel {
    
    private var nickName = ""
    
    private var availableCompleteButtonRelay = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()
    
    private func checkNickname() {
        if nickName.count > 0 {
            availableCompleteButtonRelay.accept(true)
        }
    }
    
}

extension OnboardingViewModel {
    
    struct Input {
        let nickname: Observable<String>
        let gender: Observable<String>
    }
    
    struct Output {
        let availableCompleteButton: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        input.nickname
            .subscribe(with: self, onNext: { owner, text in
                owner.nickName = text
                owner.checkNickname()
            })
            .disposed(by: disposeBag)
        
        return Output(
            availableCompleteButton: availableCompleteButtonRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
}

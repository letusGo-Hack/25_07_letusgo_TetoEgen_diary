//
//  OnboardingViewModel.swift
//  teto-egen
//
//  Created by 서문가은 on 7/19/25.
//

import RxSwift
import RxRelay
import RxCocoa
import Foundation

enum Gender: Int {
    case male = 0
    case female
}

class OnboardingViewModel {
    
    private var nickName = ""
    private var gender = Gender.male
    private var availableCompleteButtonRelay = BehaviorRelay<Bool>(value: false)
    private var completeRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    
    private func checkNickname() {
        if nickName.count > 0 {
            availableCompleteButtonRelay.accept(true)
        }
    }
    
    private func saveData() {
        UserDefaults.standard.set(nickName, forKey: "nickname")
        UserDefaults.standard.set(gender.rawValue, forKey: "gender")
    }
}

extension OnboardingViewModel {
    
    struct Input {
        let nickname: Observable<String>
        let gender: Observable<Int>
        let completeButtonTapped: Observable<Void>
    }
    
    struct Output {
        let availableCompleteButton: Driver<Bool>
        let complete: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        input.nickname
            .subscribe(with: self, onNext: { owner, text in
                owner.nickName = text
                owner.checkNickname()
            })
            .disposed(by: disposeBag)
        
        input.gender
            .subscribe(with: self, onNext: { owner, index in
                owner.gender = Gender(rawValue: index) ?? .male
            })
            .disposed(by: disposeBag)
        
        input.completeButtonTapped
            .subscribe(with: self, onNext: { owner, _ in
                owner.saveData()
                owner.completeRelay.accept(())
            })
            .disposed(by: disposeBag)
        
        return Output(
            availableCompleteButton: availableCompleteButtonRelay.asDriver(onErrorDriveWith: .empty()),
            complete: completeRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
}

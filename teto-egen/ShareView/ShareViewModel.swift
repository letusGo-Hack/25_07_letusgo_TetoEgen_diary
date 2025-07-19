//
//  ShareViewModel.swift
//  teto-egen
//
//  Created by 서문가은 on 7/19/25.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

class ShareViewModel {
    
    private let dateTitleLabelRelay = PublishRelay<String>()
    private let emotionRelay = PublishRelay<String>()
    private let typeRelay = PublishRelay<String>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        // 이전 화면에서 데이터 받아서 처리
    }

    private func updateDateTitleLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MM월 dd일"
        let todayLabel = dateFormatter.string(from: Date())
        let nickName = UserDefaults.standard.string(forKey: "nickName") ?? "사용자"
        dateTitleLabelRelay.accept("\(todayLabel)의 \(nickName)님은")
        
    }
}

extension ShareViewModel {
    
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    
    struct Output {
        let dateTitleLabel: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        input.viewWillAppear
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.updateDateTitleLabel()
            })
            .disposed(by: disposeBag)
        
        return Output(dateTitleLabel: dateTitleLabelRelay.asDriver(onErrorDriveWith: .empty()))
    }
}

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
    
    private let dateTitleLabelRelay = BehaviorRelay(value: "")
    private let emotionRelay = BehaviorRelay(value: "")
    private let typeRelay = BehaviorRelay(value: "")
    private let imageNameRelay = BehaviorRelay(value: "")
    
    private let disposeBag = DisposeBag()
    
    init(_ data: DiaryModel) {
        updateDateTitleLabel(date: data.date)
        let gender = Gender(rawValue: UserDefaults.standard.integer(forKey: "gender"))
        let tetoEgenType = ShareTypeModel(from: data.score)
        emotionRelay.accept(tetoEgenType.description)
        typeRelay.accept("\(tetoEgenType.title)\(gender?.title ?? "남")")
        imageNameRelay.accept(tetoEgenType.imageName)
    }

    private func updateDateTitleLabel(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MM월 dd일"
        let todayLabel = dateFormatter.string(from: date)
        let nickName = UserDefaults.standard.string(forKey: "nickname") ?? "사용자"
        dateTitleLabelRelay.accept("\(todayLabel)의 \(nickName)님은")
    }
}

extension ShareViewModel {
    
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    
    struct Output {
        let dateTitleLabel: Driver<String>
        let emotionLabel: Driver<String>
        let typeLabel: Driver<String>
        let imageName: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        return Output(
            dateTitleLabel: dateTitleLabelRelay.asDriver(onErrorDriveWith: .empty()),
            emotionLabel: emotionRelay.asDriver(onErrorDriveWith: .empty()),
            typeLabel: typeRelay.asDriver(onErrorDriveWith: .empty()),
            imageName: imageNameRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
}

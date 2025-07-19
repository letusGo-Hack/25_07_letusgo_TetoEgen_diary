//
//  OnboardingView.swift
//  teto-egen
//
//  Created by 서문가은 on 7/19/25.
//

import UIKit
import SnapKit
import Then

class OnboardingView: UIView {
    
    private let titleLabel = UILabel().then {
        $0.text = "Onboarding"
        $0.font = .systemFont(ofSize: 32, weight: .bold)
    }
    
    private let nicknameLabel = UILabel().then {
        $0.text = "닉네임을 입력해주세요."
    }
    
    private let nicknameTextField = UITextField().then {
        $0.borderStyle = .roundedRect
    }
    
    private let genderLabel = UILabel().then {
        $0.text = "성별을 선택해주세요."
    }
    
    private let genderSegmentedControl = UISegmentedControl(items: ["남자", "여자"]).then {
        $0.selectedSegmentIndex = 0
    }
    
    private let completeButton = UIButton(type: .system).then {
        $0.backgroundColor = .blue
        $0.setTitle("완료", for: .normal)
        $0.layer.cornerRadius = 20
        $0.isEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        [
            titleLabel,
            nicknameLabel,
            nicknameTextField,
            genderLabel,
            genderSegmentedControl,
            completeButton
        ].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).inset(20)
            $0.centerX.equalToSuperview()
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
        }
        
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
        
        genderLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
        }
        
        genderSegmentedControl.snp.makeConstraints {
            $0.top.equalTo(genderLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
        
        completeButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(60)
        }
    }

}

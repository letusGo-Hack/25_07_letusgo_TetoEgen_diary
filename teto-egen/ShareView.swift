//
//  ShareView.swift
//  teto-egen
//
//  Created by 서문가은 on 7/19/25.
//

import UIKit
import Then
import SnapKit

class ShareView: UIView {
    
    private let exitButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
        $0.tintColor = .white
    }

    private let dateTitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .label
        $0.textAlignment = .center
        $0.text = "7월 19일의 mun님은"
        $0.textColor = .white
    }
    
    private let emotionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 30, weight: .semibold)
        $0.text = "감정이 요동치는"
        $0.textAlignment = .center
        $0.textColor = .white
    }
    
    private let typeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 40, weight: .bold)
        $0.text = "에겐인"
        $0.textAlignment = .center
        $0.textColor = .white
    }
    
    private let characterImageView = UIImageView().then {
        $0.image = UIImage(named: "teto1")
        $0.contentMode = .scaleAspectFit
    }
    
    private let shareButton = UIButton(type: .system).then {
        $0.setTitle("공유하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .systemBlue
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(cgColor: CGColor(red: 0.149, green: 0.182, blue: 0.202, alpha: 1))
        [
            exitButton,
            dateTitleLabel,
            emotionLabel,
            typeLabel,
            characterImageView,
            shareButton
        ].forEach {
            addSubview($0)
        }
        
        exitButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).inset(10)
            $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailing).inset(10)
            $0.size.equalTo(50)
        }
        
        dateTitleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
        
        emotionLabel.snp.makeConstraints {
            $0.top.equalTo(dateTitleLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
        
        typeLabel.snp.makeConstraints {
            $0.top.equalTo(emotionLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
        
        characterImageView.snp.makeConstraints {
            $0.top.equalTo(typeLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(300)
        }
        
        shareButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(150)
            $0.height.equalTo(40)
        }
    }
    
}

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
    
    let exitButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
        $0.tintColor = .white
    }

    var dateTitleLabel = UILabel().then {
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
        $0.textColor = .label
        $0.textAlignment = .center
        $0.textColor = .white
    }
    
    var emotionLabel = UILabel().then {
        $0.font = UIFont(name: "Pretendard-Bold", size: 20)
        $0.textAlignment = .center
        $0.textColor = .white
    }
    
    var typeLabel = UILabel().then {
        $0.font = UIFont(name: "Pretendard-Bold", size: 40)
        $0.textAlignment = .center
        $0.textColor = .white
    }
    
    var characterImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    let shareButton = UIButton(type: .system).then {
        let title = "공유하기"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Pretendard-Bold", size: 14),
            .foregroundColor: UIColor.white
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        
        $0.setAttributedTitle(attributedTitle, for: .normal)
        $0.layer.cornerRadius = 15
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
            $0.top.equalTo(exitButton.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
        
        emotionLabel.snp.makeConstraints {
            $0.top.equalTo(dateTitleLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
        
        typeLabel.snp.makeConstraints {
            $0.top.equalTo(emotionLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
        
        characterImageView.snp.makeConstraints {
            $0.top.equalTo(typeLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(400)
        }
        
        shareButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(150)
            $0.height.equalTo(40)
        }
    }
    
}

extension ShareView {
    
    // 이미지로 변환하는 메서드
    func asImage() -> UIImage {
        [
            exitButton,
            shareButton
        ].forEach { $0.isHidden = true }
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image =  renderer.image { context in
            layer.render(in: context.cgContext)
        }
        
        [
            exitButton,
            shareButton
        ].forEach { $0.isHidden = false }
        
        return image
    }
}

extension ShareView {
    
    func updateImage(name: String) {
        characterImageView.image = UIImage(named: name)
    }
}

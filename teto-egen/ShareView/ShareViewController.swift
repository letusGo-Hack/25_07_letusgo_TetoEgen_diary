//
//  ShareViewController.swift
//  teto-egen
//
//  Created by 서문가은 on 7/19/25.
//

import UIKit
import RxSwift
import RxCocoa

class ShareViewController: UIViewController {
    
    private let shareView = ShareView()
    private let shareViewModel: ShareViewModel
    private let disposeBag = DisposeBag()
    
    init(shareViewModel: ShareViewModel) {
        self.shareViewModel = shareViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = shareView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
        bind()
    }
    
    func setupButton() {
        shareView.exitButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.exitButtonTapped()
        }, for: .touchUpInside)
        shareView.shareButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.shareButtonTapped()
        }, for: .touchUpInside)
    }

}

extension ShareViewController {
    
    private func exitButtonTapped() {
        dismiss(animated: true)
    }
    
    private func shareButtonTapped() {
        let image = shareView.asImage()
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}

extension ShareViewController {
 
    private func bind() {
        let viewWillAppears = rx.methodInvoked(#selector(viewWillAppear)).map { _ in }
        let input = ShareViewModel.Input(viewWillAppear: viewWillAppears)
        let output = shareViewModel.transform(input: input)
        
        output.dateTitleLabel
            .drive(shareView.dateTitleLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.emotionLabel
            .drive(shareView.emotionLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.typeLabel
            .drive(shareView.typeLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

//
//  ShareViewController.swift
//  teto-egen
//
//  Created by 서문가은 on 7/19/25.
//

import UIKit

class ShareViewController: UIViewController {
    
    private let shareView = ShareView()
    
    override func loadView() {
        view = shareView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
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

//
//  OnboardingViewController.swift
//  teto-egen
//
//  Created by 서문가은 on 7/19/25.
//

import UIKit
import SnapKit
import Then

class OnboardingViewController: UIViewController {
    
    private let onboardingView = OnboardingView()
    private let onboardingViewModel = OnboardingViewModel()
   
    override func loadView() {
        view = onboardingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    
}

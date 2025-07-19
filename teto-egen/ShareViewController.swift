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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

}

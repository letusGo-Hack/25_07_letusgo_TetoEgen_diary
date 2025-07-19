//
//  ShareLevelModel.swift
//  teto-egen
//
//  Created by 서문가은 on 7/19/25.
//

enum ShareLevelModel: Int {
    case one = 1
    case two
    case three

    init(diff: Int) {
        switch diff {
        case ..<3: self = .one
        case 3..<6: self = .two
        default: self = .three
        }
    }
}

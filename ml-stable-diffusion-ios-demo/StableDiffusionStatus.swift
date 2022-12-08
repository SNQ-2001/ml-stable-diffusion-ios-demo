//
//  StableDiffusionStatus.swift
//  ml-stable-diffusion-ios-demo
//
//  Created by 宮本大新 on 2022/12/08.
//

import Foundation

enum StableDiffusionStatus {
    case ready
    case loadStart
    case loadFinish
    case generateStart
    case generateFinish
    case error

    var message: String {
        switch self {
        case .ready:
            return "準備中"
        case .loadStart:
            return "モデルの読み込みを開始しました"
        case .loadFinish:
            return "モデルの読み込みが終了しました"
        case .generateStart:
            return "画像生成を開始しました"
        case .generateFinish:
            return "画像生成が終了しました"
        case .error:
            return "エラーが発生しました"
        }
    }
}

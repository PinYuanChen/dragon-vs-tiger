//
// Created on 2022/12/9.
//

import Foundation

struct SelectedPlayModel {
    let cateCode: String
    let playCode: String
    let endPoint: CGPoint
}

struct PlayBetInfoModel {
    let playCateCode: String
    let playCode: String
    let betMoney: Int
    let hadBet: Bool
}

struct UpdateSelectedPlayModel {
    let playCateCode: String
    let playCode: String
    let betMoneyString: String
    let hadBetMoneyString: String
}

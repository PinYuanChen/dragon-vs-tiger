//
//  Int+Ext.swift
//  DT
//
//  Created by Champion Chen on 2023/1/14.
//

import Foundation

extension Int {
    var toMoneyString: String {
        let moneyString = "\(self)"
        
        switch moneyString.count {
        case let k where (k >= 4 && k < 7):
            let result = self / 1000
            return "\(result)K"
        case let million where (million >= 7 && million < 10):
            let result = self.quotientAndRemainder(dividingBy: 1000000)
            let str = "\(result.quotient)M"
            return result.remainder > 0 ? (str + "...") : str
        case let billion where billion >= 10:
            let result = self.quotientAndRemainder(dividingBy: 1000000000)
            let str = "\(result.quotient)B"
            return result.remainder > 0 ? (str + "...") : str
        default:
            return ""
        }
    }
}

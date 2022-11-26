//
//  String+Ext.swift
//  DT
//
//  Created by Champion Chen on 2022/11/26.
//

import UIKit

extension String {
    func hexColorWithAlpha(_ alpha: CGFloat) -> UIColor {
        let hexString: String = trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let _ = hexString.range(of: "^#?[a-fA-F0-9]{6}$",
                                      options: .regularExpression) else { return .clear }
        
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        return UIColor(red: CGFloat((color & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((color & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(color & 0x0000FF) / 255.0,
                       alpha: alpha)
    }
}

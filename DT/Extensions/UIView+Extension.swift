//
// Created on 2022/12/12.
//

import UIKit

extension UIView {
    func fadeInAndOut(duration: TimeInterval,
                      showTime: TimeInterval = 2.0,
                      delay: TimeInterval = 0.0,
                      completion: @escaping () -> Void = { () -> Void in }) {
        self.alpha = 0
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn) {
            self.alpha = 1.0
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + showTime) {
                self.fadeOut(duration: duration, delay: delay) {
                    completion()
                }
            }
        }
    }
    
    func fadeIn(duration: TimeInterval, delay: TimeInterval = 0.0, completion: @escaping () -> Void) {
        self.alpha = 0
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn) {
            self.alpha = 1.0
        } completion: { _ in
            completion()
        }
    }
    
    func fadeOut(duration: TimeInterval, delay: TimeInterval = 0.0, completion: @escaping () -> Void) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn) {
            self.alpha = 0.0
        } completion: { _ in
           completion()
        }
    }
}

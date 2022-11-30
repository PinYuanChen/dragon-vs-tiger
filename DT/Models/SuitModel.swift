
import UIKit

enum Suit: Int {
    case club
    case diamond
    case heart
    case spade
    
    var color: UIColor {
        switch self {
        case .club, .spade:
            return .black
        case .diamond, .heart:
            return .red
        }
    }
    
    var title: String {
        switch self {
        case .club:
            return "♣"
        case .heart:
            return "♥"
        case .diamond:
            return "♦"
        case .spade:
            return "♠"
        }
    }
}

struct SuitModel {
    let suit: Suit
    let number: Int
}

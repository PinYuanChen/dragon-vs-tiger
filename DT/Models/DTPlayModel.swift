
import Foundation

struct DTPlayCateModel: Codable {
    let cateCode: String
    let playType: [DTPlayModel]
}

struct DTPlayModel: Codable {
    let playCode: DTPlayOption
    let odds: String
}

enum DTPlayOption: String, Codable {
    case dragon
    case tie
    case tiger
    
    var title: String {
        switch self {
        case .dragon:
            return "龍"
        case .tie:
            return "和"
        case .tiger:
            return "虎"
        }
    }
}

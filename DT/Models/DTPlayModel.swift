
import Foundation

struct DTPlayCateModel: Codable {
    let cateCode: String
    let playType: [DTPlayModel]
}

struct DTPlayModel: Codable {
    let playCode: String
    let odds: String
}

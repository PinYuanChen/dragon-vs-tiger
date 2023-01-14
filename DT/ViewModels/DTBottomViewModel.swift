
import Foundation
import RxSwift
import RxCocoa

protocol DTBottomViewModelPrototype {
    var output: DTBottomViewModelOutput { get }
    var input: DTBottomViewModelInput { get }
}

protocol DTBottomViewModelOutput {
    var chipMoney: Observable<Int> { get }
}

protocol DTBottomViewModelInput {
    func mapToChipMoney(_ index: Int)
}

class DTBottomViewModel: DTBottomViewModelPrototype {

    var output: DTBottomViewModelOutput { self }
    var input: DTBottomViewModelInput { self }

    private let chipItems = ChipType.allCases
    private let _chipMoney = BehaviorRelay<Int?>(value: nil)
}

// MARK: - Output
extension DTBottomViewModel: DTBottomViewModelOutput {
    var chipMoney: Observable<Int> {
        _chipMoney.compactMap { $0 }.asObservable()
    }
}

// MARK: - Input
extension DTBottomViewModel: DTBottomViewModelInput {
    func mapToChipMoney(_ index: Int) {
        let money = chipItems[index].number
        _chipMoney.accept(money)
    }
}

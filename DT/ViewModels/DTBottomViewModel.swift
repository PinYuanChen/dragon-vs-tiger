
import Foundation
import RxSwift
import RxCocoa

protocol DTBottomViewModelPrototype {
    var output: DTBottomViewModelOutput { get }
    var input: DTBottomViewModelInput { get }
}

protocol DTBottomViewModelOutput {
}

protocol DTBottomViewModelInput {
}

class DTBottomViewModel: DTBottomViewModelPrototype {

    var output: DTBottomViewModelOutput { self }
    var input: DTBottomViewModelInput { self }

    private let disposeBag = DisposeBag()
}

// MARK: - Output
extension DTBottomViewModel: DTBottomViewModelOutput {
}

// MARK: - Input
extension DTBottomViewModel: DTBottomViewModelInput {
}

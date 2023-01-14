
import Foundation
import RxSwift
import RxCocoa

protocol DTPlayViewModelPrototype {
    var output: DTPlayViewModelOutput { get }
    var input: DTPlayViewModelInput { get }
}

protocol DTPlayViewModelOutput {
}

protocol DTPlayViewModelInput {
}

class DTPlayViewModel {

    var output: DTPlayViewModelOutput { self }
    var input: DTPlayViewModelInput { self }

    private let disposeBag = DisposeBag()
}

// MARK: - Output
extension DTPlayViewModel: DTPlayViewModelOutput {
}

// MARK: - Input
extension DTPlayViewModel: DTPlayViewModelInput {
}

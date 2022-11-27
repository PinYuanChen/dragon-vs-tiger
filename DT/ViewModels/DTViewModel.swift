
import Foundation
import RxSwift
import RxCocoa

protocol DTViewModelPrototype {
    var output: DTViewModelOutput { get }
    var input: DTViewModelInput { get }
}

protocol DTViewModelOutput {
}

protocol DTViewModelInput {
}

class DTViewModel {

    var output: DTViewModelOutput { self }
    var input: DTViewModelInput { self }

    private let disposeBag = DisposeBag()
}

extension DTViewModel: DTViewModelOutput {
}

extension DTViewModel: DTViewModelInput {
}


import Foundation
import RxSwift
import RxCocoa

protocol DTViewModelPrototype {
    var output: DTViewModelOutput { get }
    var input: DTViewModelInput { get }
}

protocol DTViewModelOutput {
    var lastGameResult: Observable<GameResultModel> { get }
    var gameResult: Observable<GameResultModel> { get }
}

protocol DTViewModelInput {
    func getLastGameResult()
    func getGameResult()
}

class DTViewModel: DTViewModelPrototype {

    var output: DTViewModelOutput { self }
    var input: DTViewModelInput { self }

    private let _lastGameResult = PublishRelay<GameResultModel>()
    private let _gameResult = BehaviorRelay<GameResultModel?>(value: nil)
    private let disposeBag = DisposeBag()
}

extension DTViewModel: DTViewModelOutput {
    var lastGameResult: RxSwift.Observable<GameResultModel> {
        _lastGameResult.asObservable()
    }
    
    var gameResult: RxSwift.Observable<GameResultModel> {
        _gameResult.compactMap { $0 }.asObservable()
    }
}

extension DTViewModel: DTViewModelInput {
    func getLastGameResult() {
        let dragon = SuitModel(suit: .club, number: 10)
        let tiger = SuitModel(suit: .diamond, number: 9)
        _lastGameResult.accept(.init(dragon: dragon,
                                 tiger: tiger))
    }
    
    func getGameResult() {
        let dragon = SuitModel(suit: .club, number: 10)
        let tiger = SuitModel(suit: .diamond, number: 9)
        _gameResult.accept(.init(dragon: dragon,
                                 tiger: tiger))
    }
}

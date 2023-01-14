
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
    var showCurrentTime: Observable<Void> { get }
    var showWinPlay: Observable<String> { get }
}

protocol DTViewModelInput {
    func getLastGameResult()
    func getGameResult()
    func getWinPlay()
    func getCurrentTime()
}

class DTViewModel: DTViewModelPrototype {
    
    var output: DTViewModelOutput { self }
    var input: DTViewModelInput { self }
    
    private let _lastGameResult = PublishRelay<GameResultModel>()
    private let _gameResult = BehaviorRelay<GameResultModel?>(value: nil)
    private let _showCurrentTime = PublishRelay<Void>()
    private var winPlays = ""
    private let _showWinPlay = PublishRelay<String>()
    private let disposeBag = DisposeBag()
}

// MARK: - Output
extension DTViewModel: DTViewModelOutput {
    
    var lastGameResult: Observable<GameResultModel> {
        _lastGameResult.asObservable()
    }
    
    var gameResult: Observable<GameResultModel> {
        _gameResult.compactMap { $0 }.asObservable()
    }
    
    var showCurrentTime: Observable<Void> {
        _showCurrentTime.asObservable()
    }
    
    var showWinPlay: Observable<String> {
        _showWinPlay.asObservable()
    }
}

// MARK: Input
extension DTViewModel: DTViewModelInput {
    
    func getLastGameResult() {
        let dragon = SuitModel(suit: .club, number: 10)
        let tiger = SuitModel(suit: .diamond, number: 9)
        let result = GameResultModel(dragon: dragon, tiger: tiger)
        _lastGameResult.accept(result)
    }
    
    func getGameResult() {
        let dragon = getSuitResult()
        let tiger = getSuitResult()
        
        if dragon.number > tiger.number {
            winPlays = "dragon"
        } else if dragon.number < tiger.number {
            winPlays = "tiger"
        } else {
            winPlays = "tie"
        }
        
        _gameResult.accept(.init(dragon: dragon,
                                 tiger: tiger))
    }
    
    func getWinPlay() {
        _showWinPlay.accept(winPlays)
    }
    
    func getCurrentTime() {
        _showCurrentTime.accept(())
    }
}

// MARK: - Private functions
private extension DTViewModel {
    func getSuitResult() -> SuitModel {
        let suit = Suit(rawValue: .random(in: 0...3)) ?? .club
        let num = Int.random(in: 1...13)
        return .init(suit: suit, number: num)
    }
    
}


import Foundation
import RxSwift
import RxCocoa

protocol DTViewModelPrototype {
    var output: DTViewModelOutput { get }
    var input: DTViewModelInput { get }
}

protocol DTViewModelOutput {
    var playOptions: Observable<DTPlayCateModel> { get }
    var lastGameResult: Observable<GameResultModel> { get }
    var gameResult: Observable<GameResultModel> { get }
    var showCurrentTime: Observable<Void> { get }
    var showWinPlay: Observable<String> { get }
    var updateSelectedPlayModels: Observable<[UpdateSelectedPlayModel]> { get }
    var clearAllBet: Observable<Void> { get }
}

protocol DTViewModelInput {
    func getPlayOptions()
    func getLastGameResult()
    func getGameResult()
    func getWinPlay()
    func getCurrentTime()
    func getSelectedChipIndex(_ index: Int)
    func getSelectedPlay(_ play: SelectedPlayModel)
    func cancelReadyBet()
    func confirmReadyBet()
    func clearAllBetInfo(withAnimation: Bool)
}

class DTViewModel: DTViewModelPrototype {
    
    var output: DTViewModelOutput { self }
    var input: DTViewModelInput { self }
    
    private let _playOptions = PublishRelay<DTPlayCateModel>()
    private let _lastGameResult = PublishRelay<GameResultModel>()
    private let _gameResult = BehaviorRelay<GameResultModel?>(value: nil)
    private let _showCurrentTime = PublishRelay<Void>()
    private var winner = ""
    private let _showWinPlay = PublishRelay<String>()
    private let _selectedChipIndex = BehaviorRelay<Int>(value: 0)
    private let chipItems = ChipType.allCases
    private var hadBet = [PlayBetInfoModel]()
    private var readyBet = [PlayBetInfoModel]()
    private let _updateSelectedPlayModels = BehaviorRelay<[UpdateSelectedPlayModel]?>(value: nil)
    private let _clearAllBet = PublishRelay<Void>()
    private let _clearAllBetWithoutAnimation = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
}

// MARK: - Output
extension DTViewModel: DTViewModelOutput {
    
    var playOptions: Observable<DTPlayCateModel> {
        _playOptions.asObservable()
    }
    
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
    
    var updateSelectedPlayModels: Observable<[UpdateSelectedPlayModel]> {
        _updateSelectedPlayModels.compactMap { $0 }.asObservable()
    }
    
    var clearAllBet: Observable<Void> {
        _clearAllBet.asObservable()
    }
}

// MARK: Input
extension DTViewModel: DTViewModelInput {
    
    func getPlayOptions() {
        guard let options = loadJsonData("DT") else {
            return
        }
        _playOptions.accept(options)
    }
    
    func getLastGameResult() {
        let dragon = SuitModel(suit: .club, number: 10)
        let tiger = SuitModel(suit: .diamond, number: 9)
        let result = GameResultModel(dragon: dragon, tiger: tiger)
        _lastGameResult.accept(result)
        _gameResult.accept(result)
    }
    
    func getGameResult() {
        let dragon = getSuitResult()
        let tiger = getSuitResult()
        
        if dragon.number > tiger.number {
            winner = "dragon"
        } else if dragon.number < tiger.number {
            winner = "tiger"
        } else {
            winner = "tie"
        }
        
        _gameResult.accept(.init(dragon: dragon,
                                 tiger: tiger))
    }
    
    func getCurrentTime() {
        _showCurrentTime.accept(())
    }
    
    func getWinPlay() {
        _showWinPlay.accept(winner)
    }
    
    func getSelectedChipIndex(_ index: Int) {
        _selectedChipIndex.accept(index)
    }
    
    func getSelectedPlay(_ play: SelectedPlayModel) {
        let betMoney = chipItems[_selectedChipIndex.value].number
        let playReadyBetMoney = readyBet.filter { $0.playCateCode == play.cateCode &&
            $0.playCode == play.playCode
        }.reduce(0) { $0 + $1.betMoney }
        
        // TODO: check user's limit
        
        let betInfoModel = PlayBetInfoModel(playCateCode: play.cateCode,
                                            playCode: play.playCode,
                                            betMoney: betMoney,
                                            hadBet: false)
        readyBet.append(betInfoModel)
        reloadBetInfo()
    }
    
    func cancelReadyBet() {
        readyBet.removeAll()
        reloadBetInfo()
    }
    
    func confirmReadyBet() {
        let addBetInfo = readyBet.map {
            PlayBetInfoModel(playCateCode: $0.playCateCode,
                             playCode: $0.playCode,
                             betMoney: $0.betMoney,
                             hadBet: true)
        }
        hadBet += addBetInfo
        readyBet.removeAll()
        reloadBetInfo()
    }
    
    func clearAllBetInfo(withAnimation: Bool) {
        hadBet.removeAll()
        readyBet.removeAll()
        if withAnimation {
            _clearAllBet.accept(())
        } else {
            _clearAllBetWithoutAnimation.accept(())
        }
        _updateSelectedPlayModels.accept([])
    }
}

// MARK: - Private functions
private extension DTViewModel {
    func getSuitResult() -> SuitModel {
        let suit = Suit(rawValue: .random(in: 0...3)) ?? .club
        let num = Int.random(in: 1...13)
        return .init(suit: suit, number: num)
    }
    
    func loadJsonData(_ cateCode: String) -> DTPlayCateModel? {
        
        let gameModel: DTPlayCateModel
        
        guard let path = Bundle.main.path(forResource: "DTPlay", ofType: "json"),
              let data: Data = try? .init(contentsOf: .init(fileURLWithPath: path), options: .mappedIfSafe)
        else {
            return nil
        }
        
        do {
            gameModel = try JSONDecoder().decode(DTPlayCateModel.self, from: data)
            return gameModel
        } catch {
            assert(false, "\(error)")
            return nil
        }
    }
    
    func reloadBetInfo() {
        let combinedArray = hadBet + readyBet
        let dict = Dictionary(grouping: combinedArray) {
            $0.playCateCode + "." + $0.playCode
        }
        
        var outputResult: [UpdateSelectedPlayModel] = []
        
        let allKeys = dict.keys
        
        for key in allKeys {
            guard let ary = dict[key],
                  let cateCode = key.components(separatedBy: ".").first,
                  let playCode = key.components(separatedBy: ".").last else { continue }
            
            let readyBet = ary.filter { !$0.hadBet }
            let hadBet = ary.filter { $0.hadBet }
            let readyBetMoney = readyBet.reduce(0) { $0 + $1.betMoney }
            let hadBetMoney = hadBet.reduce(0) { $0 + $1.betMoney }
            
            let model = UpdateSelectedPlayModel(playCateCode: cateCode,
                                                playCode: playCode,
                                                betMoneyString: getMoneyString(readyBetMoney),
                                                hadBetMoneyString: getMoneyString(hadBetMoney))
            outputResult.append(model)
        }
        _updateSelectedPlayModels.accept(outputResult)
    }
    
    func getMoneyString(_ money: Int) -> String {
        let moneyString = "\(money)"
        switch moneyString.count {
        case let k where (k >= 4 && k < 7):
            let result = money / 1000
            return "\(result)K"
        case let million where (million >= 7 && million < 10):
            let result = money.quotientAndRemainder(dividingBy: 1000000)
            if result.remainder > 0 {
                return "\(result.quotient)M..."
            } else {
                return "\(result.quotient)M"
            }
        case let billion where billion >= 10:
            let result = money.quotientAndRemainder(dividingBy: 1000000000)
            if result.remainder > 0 {
                return "\(result.quotient)B..."
            } else {
                return "\(result.quotient)B"
            }
        default:
            return ""
        }
    }
}

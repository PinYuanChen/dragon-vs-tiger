
import Foundation
import RxSwift
import RxCocoa

protocol DTPlayViewModelPrototype {
    var output: DTPlayViewModelOutput { get }
    var input: DTPlayViewModelInput { get }
}

protocol DTPlayViewModelOutput {
    var playOptions: Observable<DTPlayCateModel> { get }
    var clearAllBet: Observable<Void> { get }
    var updateSelectedPlayModels: Observable<[UpdateSelectedPlayModel]> { get }
}

protocol DTPlayViewModelInput {
    func getPlayOptions()
    func getCurrentChipMoney(_ money: Int)
    func getSelectedPlay(selectPlay play: SelectedPlayModel)
    func cancelReadyBet()
    func confirmReadyBet()
    func clearAllBetInfo(withAnimation: Bool)
}

class DTPlayViewModel: DTPlayViewModelPrototype {

    var output: DTPlayViewModelOutput { self }
    var input: DTPlayViewModelInput { self }

    private var hadBet = [PlayBetInfoModel]()
    private var readyBet = [PlayBetInfoModel]()
    private var betMoney = 0
    private let _playOptions = PublishRelay<DTPlayCateModel>()
    private let _clearAllBet = PublishRelay<Void>()
    private let _clearAllBetWithoutAnimation = PublishRelay<Void>()
    private let _updateSelectedPlayModels = BehaviorRelay<[UpdateSelectedPlayModel]?>(value: nil)
}

// MARK: - Output
extension DTPlayViewModel: DTPlayViewModelOutput {
    
    var playOptions: RxSwift.Observable<DTPlayCateModel> {
        _playOptions.asObservable()
    }
    
    var clearAllBet: Observable<Void> {
        _clearAllBet.asObservable()
    }
    
    var updateSelectedPlayModels: Observable<[UpdateSelectedPlayModel]> {
        _updateSelectedPlayModels.compactMap { $0 }.asObservable()
    }
}

// MARK: - Input
extension DTPlayViewModel: DTPlayViewModelInput {
    
    func getPlayOptions() {
        guard let options = loadJsonData("DT") else {
            return
        }
        _playOptions.accept(options)
    }
    
    func getCurrentChipMoney(_ money: Int) {
        betMoney = money
    }
        
    func getSelectedPlay(selectPlay play: SelectedPlayModel) {
        let playReadyBetMoney = readyBet.filter {
            $0.playCateCode == play.cateCode &&
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

private extension DTPlayViewModel {
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
                                                betMoneyString: readyBetMoney.toMoneyString,
                                                hadBetMoneyString: hadBetMoney.toMoneyString)
            outputResult.append(model)
        }
        _updateSelectedPlayModels.accept(outputResult)
    }
}

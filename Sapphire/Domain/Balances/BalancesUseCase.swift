import Foundation
import RxSwift

protocol BalancesUseCaseProtocol {
    func fetchCurrentBalanceData() -> Single<BalanceData>
}

struct BalancesUseCase: BalancesUseCaseProtocol {
    let bittrexRepository: BittrexRepositoryProtocol

    func fetchCurrentBalanceData() -> Single<BalanceData> {
        return Single.zip(
            bittrexRepository.fetchCurrentBalances(),
            bittrexRepository.fetchCurrentMarketSummaries(),
            bittrexRepository.fetchCurrencies()
        ).map(BalancesUseCase.translate)
    }

    static func translate(balances: [Balance], marketSummaries: [MarketSummary], currencies: [Currency]) -> BalanceData {
        let infoList: [BalanceData.CurrencyInfo] = balances.map { balance in
            let estimatedBTCValue: Int64
            if balance.currency == "BTC" {
                estimatedBTCValue = Int64(balance.balance * Bitcoin.satoshi)
            } else {
                let marketName = "BTC-\(balance.currency)"
                if let marketSummary = marketSummaries.first(where: { $0.marketName == marketName }) {
                    estimatedBTCValue = Int64(balance.balance * marketSummary.last * Bitcoin.satoshi)
                } else {
                    estimatedBTCValue = 0
                }
            }
            let longName = currencies.first(where: { $0.currency == balance.currency })?.currencyLong ?? balance.currency
            return BalanceData.CurrencyInfo(name: balance.currency, longName: longName, balance: balance.balance, estimatedBTCValue: estimatedBTCValue)
        }
            .filter { $0.balance > 0 }
            .sorted { a, b in a.estimatedBTCValue > b.estimatedBTCValue}
        return BalanceData(date: Date(), items: infoList)
    }
}

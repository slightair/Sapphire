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
        let usdtBTCMarket = marketSummaries.first(where: { $0.marketName == "USDT-BTC" })

        var infoList: [BalanceData.CurrencyInfo] = balances.map { balance in
            let estimatedBTCValue: Double
            var last: Double?
            var high: Double?
            var low: Double?
            var change: Double?

            if balance.currency == "BTC" {
                estimatedBTCValue = balance.balance * Bitcoin.satoshi
                if let marketSummary = usdtBTCMarket {
                    last = marketSummary.last
                    high = marketSummary.high
                    low = marketSummary.low
                    change = (marketSummary.last - marketSummary.prevDay) / marketSummary.prevDay
                }
            } else {
                let marketName = "BTC-\(balance.currency)"
                if let marketSummary = marketSummaries.first(where: { $0.marketName == marketName }) {
                    estimatedBTCValue = balance.balance * marketSummary.last * Bitcoin.satoshi
                    last = marketSummary.last * Bitcoin.satoshi
                    high = marketSummary.high * Bitcoin.satoshi
                    low = marketSummary.low * Bitcoin.satoshi
                    change = (marketSummary.last - marketSummary.prevDay) / marketSummary.prevDay
                } else {
                    estimatedBTCValue = 0
                }
            }
            let longName = currencies.first(where: { $0.currency == balance.currency })?.currencyLong ?? balance.currency
            return BalanceData.CurrencyInfo(name: balance.currency,
                                            longName: longName,
                                            balance: balance.balance,
                                            last: last,
                                            high: high,
                                            low: low,
                                            change: change,
                                            estimatedBTCValue: estimatedBTCValue)
        }
        .filter { $0.balance > 0 }
        .sorted { a, b in a.estimatedBTCValue > b.estimatedBTCValue }

        let usdtBTCPrice: Double
        if let usdtBTCMarket = usdtBTCMarket {
            usdtBTCPrice = usdtBTCMarket.last
        } else {
            usdtBTCPrice = 0
        }

        let btcAssets: Double = Double(infoList.reduce(0) { r, c in r + c.estimatedBTCValue }) / Double(Bitcoin.satoshi)
        let usdtAssets: Double = btcAssets * usdtBTCPrice

        if let btcIndex = infoList.index(where: { $0.name == "BTC" }) {
            let btcInfo = infoList.remove(at: btcIndex)
            infoList.insert(btcInfo, at: 0)
        }

        return BalanceData(
            date: Date(),
            usdtAssets: usdtAssets,
            btcAssets: btcAssets,
            items: infoList
        )
    }
}

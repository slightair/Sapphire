import Foundation
import RxSwift

protocol BalancesUseCaseProtocol {
    func fetchCurrentBalanceData() -> Single<BalanceData>
}

struct BalancesUseCase: BalancesUseCaseProtocol {
    let bittrexRepository: BittrexRepositoryProtocol
    let needsChart: Bool

    func fetchCurrentBalanceData() -> Single<BalanceData> {
        let needsChart = self.needsChart

        return Single.zip(
            bittrexRepository.fetchCurrentBalances()
                .flatMap { balances -> Single<[(Balance, Chart?)]> in
                    if needsChart {
                        return Observable.zip(
                            balances.map { balance -> Observable<(Balance, Chart?)> in
                                let market = balance.currency == "BTC" ? "USDT-BTC" : "BTC-\(balance.currency)"
                                return self.bittrexRepository.fetchCurrentChart(market: market, tickInterval: .thirtyMin)
                                    .map { (balance, $0) }
                                    .asObservable()
                            }
                        ).asSingle()
                    }
                    return .just(balances.map { ($0, nil) })
                },
            bittrexRepository.fetchCurrentMarketSummaries(),
            bittrexRepository.fetchCurrencies(),
            bittrexRepository.fetchMarkets()
        ).map(BalancesUseCase.translate)
    }

    static func translate(balances: [(Balance, Chart?)], marketSummaries: [MarketSummary], currencies: [Currency], markets: [Market]) -> BalanceData {
        let usdtBTCMarket = marketSummaries.first(where: { $0.marketName == "USDT-BTC" })

        var infoList: [BalanceData.CurrencyInfo] = balances.map { balance, chart in
            let estimatedBTCValue: Double
            var last: Double?
            var high: Double?
            var low: Double?
            var change: Double?
            let marketName: String

            if balance.currency == "BTC" {
                marketName = "USDT-BTC"
                estimatedBTCValue = balance.balance * Bitcoin.satoshi
                if let marketSummary = usdtBTCMarket {
                    last = marketSummary.last
                    high = marketSummary.high
                    low = marketSummary.low
                    change = (marketSummary.last - marketSummary.prevDay) / marketSummary.prevDay
                }
            } else {
                marketName = "BTC-\(balance.currency)"
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
            let logoImageURL = markets.first(where: { $0.name == marketName })?.logoImageURL

            return BalanceData.CurrencyInfo(name: balance.currency,
                                            longName: longName,
                                            balance: balance.balance,
                                            last: last,
                                            high: high,
                                            low: low,
                                            change: change,
                                            estimatedBTCValue: estimatedBTCValue,
                                            chart: chart,
                                            logoImageURL: logoImageURL
            )
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

        if let btcIndex = infoList.firstIndex(where: { $0.name == "BTC" }) {
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

import Foundation
import RxSwift

protocol MarketSummariesUseCaseProtocol {
    func fetchCurrentMarketSummaryData() -> Single<[MarketSummaryData]>
}

struct MarketSummariesUseCase: MarketSummariesUseCaseProtocol {
    let bittrexRepository: BittrexRepositoryProtocol

    func fetchCurrentMarketSummaryData() -> Single<[MarketSummaryData]> {
        return Single.zip(
            bittrexRepository.fetchCurrentMarketSummaries(),
            bittrexRepository.fetchCurrencies(),
            bittrexRepository.fetchMarkets()
        ).map(MarketSummariesUseCase.translate)
    }

    static func translate(marketSummaries: [MarketSummary], currencies: [Currency], markets: [Market]) -> [MarketSummaryData] {
        var summaries: [String: [MarketSummaryData.CurrencyInfo]] = [:]

        for marketSummary in marketSummaries {
            let currencyPair = marketSummary.marketName.components(separatedBy: "-")

            let group = currencyPair[0]
            let currency = currencyPair[1]
            let currencyLongName = currencies.first(where: { $0.currency == currency })?.currencyLong ?? currency
            let logoImageURL = markets.first(where: { $0.name == marketSummary.marketName })?.logoImageURL

            let scale = group == "BTC" ? Bitcoin.satoshi : 1

            let currencyInfo = MarketSummaryData.CurrencyInfo(
                market: marketSummary.marketName,
                name: currency,
                longName: currencyLongName,
                last: marketSummary.last * scale,
                high: marketSummary.high * scale,
                low: marketSummary.low * scale,
                baseVolume: marketSummary.baseVolume,
                change: (marketSummary.last - marketSummary.prevDay) / marketSummary.prevDay,
                logoImageURL: logoImageURL
            )

            if let array = summaries[group] {
                summaries[group] = array + [currencyInfo]
            } else {
                summaries[group] = [currencyInfo]
            }
        }

        let date = Date()
        return summaries.map { group, items in
            let groupLongName = currencies.first(where: { $0.currency == group })?.currencyLong ?? group
            return MarketSummaryData(date: date,
                                     marketGroup: groupLongName,
                                     items: items.sorted { a, b in a.baseVolume > b.baseVolume })
        }.sorted { a, b in
            a.marketGroup < b.marketGroup
        }
    }
}

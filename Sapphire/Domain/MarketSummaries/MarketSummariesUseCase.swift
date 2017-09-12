import Foundation
import RxSwift

protocol MarketSummariesUseCaseProtocol {
    func fetchCurrentMarketSummaries() -> Single<[MarketSummaryData]>
}

struct MarketSummariesUseCase: MarketSummariesUseCaseProtocol {
    let bittrexRepository: BittrexRepositoryProtocol

    func fetchCurrentMarketSummaries() -> Single<[MarketSummaryData]> {
        return Single.zip(
            bittrexRepository.fetchCurrentMarketSummaries(),
            bittrexRepository.fetchCurrencies()
        ).map(MarketSummariesUseCase.translate)
    }

    static func translate(marketSummaries: [MarketSummary], currencies: [Currency]) -> [MarketSummaryData] {
        var summaries: [String: [MarketSummaryData.CurrencyInfo]] = [:]

        for marketSummary in marketSummaries {
            let currencyPair = marketSummary.marketName.components(separatedBy: "-")

            let group = currencyPair[0]
            let currency = currencyPair[1]
            let currencyLongName = currencies.first(where: { $0.currency == currency })?.currencyLong ?? currency

            let currencyInfo = MarketSummaryData.CurrencyInfo(
                name: currency,
                longName: currencyLongName,
                last: Int64(marketSummary.last * Bitcoin.satoshi),
                high: Int64(marketSummary.high * Bitcoin.satoshi),
                low: Int64(marketSummary.low * Bitcoin.satoshi),
                change: (marketSummary.last - marketSummary.prevDay) / marketSummary.prevDay
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
                                     items: items)
        }.sorted { a, b in
            a.marketGroup < b.marketGroup
        }
    }
}

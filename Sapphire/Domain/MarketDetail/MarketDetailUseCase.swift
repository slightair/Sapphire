import Foundation
import RxSwift

protocol MarketDetailUseCaseProtocol {
    func fetchCurrentMarketDetailData(market: String, tickInterval: BittrexTickInterval) -> Single<MarketDetailData>
}

struct MarketDetailUseCase: MarketDetailUseCaseProtocol {
    let bittrexRepository: BittrexRepositoryProtocol

    func fetchCurrentMarketDetailData(market: String, tickInterval: BittrexTickInterval) -> Single<MarketDetailData> {
        return Single.zip(
            bittrexRepository.fetchCurrentChart(market: market, tickInterval: tickInterval),
            bittrexRepository.fetchCurrentMarketSummary(market: market),
            bittrexRepository.fetchOpenOrders(market: market),
            bittrexRepository.fetchOrderHistory(market: market),
            bittrexRepository.fetchCurrencies()
        )
            .map(MarketDetailUseCase.translate)
    }

    static func translate(chart: Chart, marketSummary: MarketSummary, openOrders: [Order], orderHistory: [Order], currencies: [Currency]) -> MarketDetailData {
        let currencyInfo = MarketDetailUseCase.currencyInfo(from: marketSummary, currencies: currencies)
        var sections: [MarketDetailData.Section] = [
            .chart(items: [.chartSectionItem(chart: chart)]),
            .summary(items: [.summarySectionItem(currencyInfo: currencyInfo)]),
        ]

        if openOrders.count > 0 {
            sections.append(.openOrders(items: openOrders.map { .openOrdersSectionItem(order: $0) }))
        }

        if orderHistory.count > 0 {
            sections.append(.orderHistory(items: orderHistory.map { .orderHistorySectionItem(order: $0) }))
        }

        return MarketDetailData(date: Date(), sections: sections)
    }

    static func currencyInfo(from marketSummary: MarketSummary, currencies: [Currency]) -> MarketSummaryData.CurrencyInfo {
        let currencyPair = marketSummary.marketName.components(separatedBy: "-")

        let group = currencyPair[0]
        let currency = currencyPair[1]
        let currencyLongName = currencies.first(where: { $0.currency == currency })?.currencyLong ?? currency

        let scale = group != "USDT" ? Bitcoin.satoshi : 1

        return MarketSummaryData.CurrencyInfo(
            market: marketSummary.marketName,
            name: currency,
            longName: currencyLongName,
            last: Int64(marketSummary.last * scale),
            high: Int64(marketSummary.high * scale),
            low: Int64(marketSummary.low * scale),
            baseVolume: marketSummary.baseVolume,
            change: (marketSummary.last - marketSummary.prevDay) / marketSummary.prevDay
        )
    }
}

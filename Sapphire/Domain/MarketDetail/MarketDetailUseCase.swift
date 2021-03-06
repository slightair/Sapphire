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
            bittrexRepository.fetchCurrencies(),
            bittrexRepository.fetchMarkets()
        )
        .map(MarketDetailUseCase.translate)
    }

    static func translate(chart: Chart, marketSummary: MarketSummary, openOrders: [Order], orderHistory: [Order], currencies: [Currency], markets: [Market]) -> MarketDetailData {
        let currencyInfo = MarketDetailUseCase.currencyInfo(from: marketSummary, currencies: currencies, markets: markets)
        var sections: [MarketDetailData.Section] = [
            .chart(items: [.chartSectionItem(chart: chart)]),
            .summary(items: [.summarySectionItem(currencyInfo: currencyInfo)]),
        ]

        func createOrderInfo(_ order: Order) -> OrderData.OrderInfo {
            let logoImageURL: URL?
            if let market = markets.first(where: { $0.name == order.exchange }) {
                logoImageURL = market.logoImageURL
            } else {
                logoImageURL = nil
            }

            return OrderData.OrderInfo(
                exchange: order.exchange,
                orderType: order.orderType,
                limit: order.limit,
                last: nil,
                quantity: order.quantity,
                opened: order.opened,
                closed: order.closed,
                logoImageURL: logoImageURL)
        }

        if openOrders.count > 0 {
            sections.append(.openOrders(items: openOrders.map { .openOrdersSectionItem(orderInfo: createOrderInfo($0)) }))
        }

        if orderHistory.count > 0 {
            sections.append(.orderHistory(items: orderHistory.map { .orderHistorySectionItem(orderInfo: createOrderInfo($0)) }))
        }

        return MarketDetailData(date: Date(), sections: sections)
    }

    static func currencyInfo(from marketSummary: MarketSummary, currencies: [Currency], markets: [Market]) -> MarketSummaryData.CurrencyInfo {
        let currencyPair = marketSummary.marketName.components(separatedBy: "-")

        let group = currencyPair[0]
        let currency = currencyPair[1]
        let currencyLongName = currencies.first(where: { $0.currency == currency })?.currencyLong ?? currency
        let logoImageURL = markets.first(where: { $0.name == marketSummary.marketName })?.logoImageURL

        let scale = group == "BTC" ? Bitcoin.satoshi : 1

        return MarketSummaryData.CurrencyInfo(
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
    }
}

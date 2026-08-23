/// GraphQL documents for the stock_ranking feature.
///
/// Kept out of the datasource so the Dart there reads as logic rather than as
/// a wall of embedded query text.
const String stockByRankingQuery = r'''
query stockByRanking($market: String!, $sectors: [String], $page: Int, $limit: Int) {
  jittaRanking(filter: { market: $market, sectors: $sectors, page: $page, limit: $limit }) {
    count
    data {
      id
      stockId
      symbol
      title
      jittaScore
      currency
      latestPrice
      industry
      sector {
        id
        name
      }
      market
      updatedAt
    }
  }
}
''';

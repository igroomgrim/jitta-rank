/// GraphQL documents for the stock_detail feature.
const String stockByIdQuery = r'''
    query stockById(\$stockId: Int) {
      stock(stockId: \$stockId) {
        stockId
        symbol
        name
        nativeName
        price {
          latest {
            close
            latest_price_timestamp
          }
        }
        currency
        currency_sign
        industry
        market
        jittaRankScore
        jitta {
          score {
            total
            last {
              value
            }
          }
          priceDiff {
            last {
              value
            }
          }
          factor {
            last {
              value {
                growth {
                  value
                  name
                  level
                }
                financial {
                  value
                  name
                  level
                }
                management {
                  level
                  name
                  value
                }
              }
            }
          }
        }
        loss_chance {
          last
        }
        sector {
          name
        }
        company {
          link {
            url
          }
          ipo_date
        }
        graph_price {
          first_graph_period
          graphs {
            stockPrice
            linePrice
          }
        }
        summary
        updatedAt
      }
    }
    ''';

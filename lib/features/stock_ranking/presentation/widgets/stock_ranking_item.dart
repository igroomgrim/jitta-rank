import 'package:flutter/material.dart';
import 'package:jitta_rank/core/theme/app_theme.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';

class StockRankingItem extends StatelessWidget {
  const StockRankingItem({
    super.key,
    required this.rankedStock,
    required this.onTap,
  });
  final RankedStock rankedStock;
  final Function(RankedStock) onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          onTap(rankedStock);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Symbol + Title and Price part
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: rankedStock.symbol,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: context.colors.onSurface,
                            ),
                          ),
                          TextSpan(
                            text: ' - ${rankedStock.title}',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${rankedStock.currency}${rankedStock.latestPrice}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: context.semanticColors.positive,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Jitta Score part
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jitta Score',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    rankedStock.jittaScore.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Market part
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Market',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    rankedStock.market ?? '-',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Sector part
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sector',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rankedStock.sector?.name ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

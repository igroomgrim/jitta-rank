import 'package:hive_flutter/adapters.dart';
import 'package:jitta_rank/features/stock_ranking/data/models/ranked_stock_model.dart';
import 'package:jitta_rank/features/stock_detail/data/models/stock_model.dart';

abstract class StorageService {
  Future<void> init();
  Future<void> close();
}

class StorageServiceImpl implements StorageService {
  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();
    await _openBoxes();
  }

  @override
  Future<void> close() async {
    await Hive.close();
  }

  void _registerAdapters() {
    Hive.registerAdapter(RankedStockModelAdapter());
    Hive.registerAdapter(SectorModelAdapter());
    Hive.registerAdapter(StockModelAdapter());
    Hive.registerAdapter(StockPriceModelAdapter());
    Hive.registerAdapter(StockJittaModelAdapter());
    Hive.registerAdapter(StockJittaFactorModelAdapter());
    Hive.registerAdapter(StockJittaFactorGrowthModelAdapter());
    Hive.registerAdapter(StockJittaFactorFinancialModelAdapter());
    Hive.registerAdapter(StockJittaFactorManagementModelAdapter());
    Hive.registerAdapter(StockGraphPriceItemModelAdapter());
    Hive.registerAdapter(StockGraphPriceModelAdapter());
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<RankedStockModel>('ranked_stocks');
    await Hive.openBox<SectorModel>('sectors');
    await Hive.openBox<StockModel>('stock_detail');
    await Hive.openBox<StockPriceModel>('stock_price');
    await Hive.openBox<StockJittaModel>('stock_jitta');
    await Hive.openBox<StockJittaFactorModel>('stock_jitta_factor');
    await Hive.openBox<StockJittaFactorGrowthModel>(
        'stock_jitta_factor_growth');
    await Hive.openBox<StockJittaFactorFinancialModel>(
        'stock_jitta_factor_financial');
    await Hive.openBox<StockJittaFactorManagementModel>(
        'stock_jitta_factor_management');
    await Hive.openBox<StockGraphPriceItemModel>('stock_graph_price_item');
    await Hive.openBox<StockGraphPriceModel>('stock_graph_price');
  }
}

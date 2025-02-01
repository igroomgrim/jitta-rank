import 'package:flutter_test/flutter_test.dart';
import 'package:jitta_rank/core/networking/graphql_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mockito/mockito.dart';
import '../../mocks/core/networking/mock_graphql_service.mocks.dart';

void main() {
  late GraphqlService service;
  late MockGraphQLClient mockClient;

  setUp(() {
    mockClient = MockGraphQLClient();
    service = GraphqlService(client: mockClient);
  });

  test('should perform query successfully', () async {
    // Arrange
    final response = QueryResult(
      options: QueryOptions(document: gql('')),
      source: QueryResultSource.network,
      data: {
        'stock': {'id': 1, 'symbol': 'AAPL'}
      },
    );
    when(mockClient.query(any)).thenAnswer((_) async => response);

    // Act
    final result = await service.performQuery("query { stock { id, symbol } }");

    // Assert
    expect(result.data, isNotNull);
    expect(result.data!['stock']['symbol'], 'AAPL');
  });
}

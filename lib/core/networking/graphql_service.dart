import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';

class GraphqlService {
  final GraphQLClient _client;

  GraphqlService({GraphQLClient? client}) : _client = client ?? _createClient();

  static GraphQLClient _createClient() {
    final HttpLink httpLink = HttpLink(
      ApiConstants.baseUrl,
      defaultHeaders: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    return GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(
        store: InMemoryStore(),
        partialDataPolicy: PartialDataCachePolicy.accept,
      ),
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.networkOnly,
          error: ErrorPolicy.none,
          cacheReread: CacheRereadPolicy.mergeOptimistic,
        ),
      ),
    );
  }

  Future<QueryResult> performQuery(String query,
      [Map<String, dynamic>? variables]) async {
    return await _client.query(
      QueryOptions(
        document: gql(query),
        variables: variables ?? {},
      ),
    );
  }

  // Prepare for mutation
  Future<QueryResult> performMutation(String mutation,
      [Map<String, dynamic>? variables]) async {
    return await _client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: variables ?? {},
      ),
    );
  }
}

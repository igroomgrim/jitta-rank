import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';

class GraphqlService {
  static const String _baseUrl = ApiConstants.baseUrl;

  static HttpLink httpLink = HttpLink(
    _baseUrl,
    defaultHeaders: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  static GraphQLClient client = GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(
      store: InMemoryStore(),
    ),
  );

  Future<QueryResult> performQuery(String query, [Map<String, dynamic>? variables]) async {
    return await client.query(
      QueryOptions(
        document: gql(query),
        variables: variables ?? {},
      ),
    );
  }

  Future<QueryResult> performMutation(String mutation, [Map<String, dynamic>? variables]) async {
    return await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: variables ?? {},
      ),
    );
  }
}

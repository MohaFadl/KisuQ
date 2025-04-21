import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

ValueNotifier<GraphQLClient> initGraphQLClient() {
  final HttpLink httpLink = HttpLink('https://graphql.anilist.co');
  return ValueNotifier(GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(store: InMemoryStore()),
  ));
}

String getSearchQuery(String query, String type ) {
  return """
    query {
      Page(perPage: 10) {
        media(search: "$query", type: $type) {
          id
          title {
            romaji
            english
          }
          description
          averageScore
          status
          startDate {
            year
            month
            day
          }
          coverImage {
            large
          }
          episodes
          chapters
        }
      }
    }
  """;
}


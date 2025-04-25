import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

ValueNotifier<GraphQLClient> initGraphQLClient() {
  final HttpLink httpLink = HttpLink('https://graphql.anilist.co');
  return ValueNotifier(GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(store: InMemoryStore()),
  ));
}

String getSearchQuery(String query, String type) {
  return """
    query{
  Page(perPage: 10) {
    media(search: "$query", type: $type) {
      id
      title {
        romaji
        english
        native
      }
      description(asHtml: false)
      averageScore
      status
      startDate {
        year
        month
        day
      }
      coverImage {
        large
        extraLarge
      }
      bannerImage
      genres
      studios(isMain: true) {
        nodes {
          name
        }
      }
      episodes
      chapters
      volumes
      format
      season
      seasonYear
      recommendations {
        nodes {
          mediaRecommendation {
            id
            title {
              romaji
              english
            }
            coverImage {
              large
            }
            averageScore
            genres
          }
        }
      }
      type
      popularity
      siteUrl
      trailer {
        id
        site
        thumbnail
      }
      characters {
        edges {
          node {
            id
            name {
              full
            }
            image {
              medium
            }
          }
        }
      }
      externalLinks {
        site
        url
      }
      streamingEpisodes {
        title
        url
        site
      }
      isAdult
      isLicensed
    }
  }
}
  """;
}

String getAnimeByIdQuery(int id) {
  return """
    query {
      Media(id: $id) {
        id
        title {
          romaji
          english
          native
        }
        description(asHtml: false)
        averageScore
        status
        startDate {
          year
          month
          day
        }
        coverImage {
          large
          extraLarge
        }
        bannerImage
        genres
        studios(isMain: true) {
          nodes {
            name
          }
        }
        episodes
        chapters
        volumes
        format
        season
        seasonYear
        recommendations {
          nodes {
            mediaRecommendation {
              id
              title {
                romaji
                english
              }
              coverImage {
                large
              }
              averageScore
              genres
            }
          }
        }
        type
        popularity
        siteUrl
        trailer {
          id
          site
          thumbnail
        }
        characters {
          edges {
            node {
              id
              name {
                full
              }
              image {
                medium
              }
            }
          }
        }
        externalLinks {
          site
          url
        }
        streamingEpisodes {
          title
          url
          site
        }
        isAdult
        isLicensed
      }
    }
  """;
}


Future<Map<String, dynamic>> fetchAnimeDetails(int id, GraphQLClient client) async {
  final QueryOptions options = QueryOptions(
    document: gql(getAnimeByIdQuery(id)),
  );

  final QueryResult result = await client.query(options);

  if (result.hasException) {
    throw Exception("Failed to fetch anime details: ${result.exception}");
  }

  return result.data?['Media'];
}

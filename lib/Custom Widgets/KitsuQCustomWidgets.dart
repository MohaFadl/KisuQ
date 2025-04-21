import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../APIServices/GraphQLPain.dart';



class KitsuQSearchBar extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController controller;
  final bool isFocused;
  final Function(String) onSubmitted;

  const KitsuQSearchBar({
    super.key,
    required this.focusNode,
    required this.controller,
    required this.isFocused,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isFocused ? 500 : 300,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white24),
        ),
        child: TextField(
          focusNode: focusNode,
          controller: controller,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,
          decoration: const InputDecoration(
            hintText: 'Search anime...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white70),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
      ),
    );
  }
}

class KitsuQMediaToggle extends StatelessWidget {
  final bool isAnime;
  final VoidCallback onToggle;

  const KitsuQMediaToggle({
    super.key,
    required this.isAnime,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onToggle,
      color: Colors.white12,
      shape: const CircleBorder(),
      padding: const EdgeInsets.all(20),
      elevation: 0,
      highlightElevation: 0,
      splashColor: Colors.white24,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Icon(
          isAnime ? Icons.tv : Icons.book,
          key: ValueKey<bool>(isAnime),
          color: Colors.white70,
        ),
      ),
    );
  }
}

class KitsuQTitleToggle extends StatelessWidget {
  final bool isRomaji;
  final VoidCallback onToggle;

  const KitsuQTitleToggle({
    super.key,
    required this.isRomaji,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onToggle,
      color: Colors.white12,
      shape: const CircleBorder(),
      padding: const EdgeInsets.all(20),
      elevation: 0,
      highlightElevation: 0,
      splashColor: Colors.white24,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Icon(
          isRomaji ? Icons.view_kanban_outlined : Icons.abc,
          key: ValueKey<bool>(isRomaji),
          color: Colors.white70,
        ),
      ),
    );
  }
}

class KitsuQSearchResults extends StatelessWidget {
  final String searchQuery;
  final bool isAnime;
  final bool isRomaji;

  const KitsuQSearchResults({
    super.key,
    required this.searchQuery,
    required this.isRomaji,
    required this.isAnime,
  });

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(getSearchQuery(searchQuery, isAnime ? "ANIME" : "MANGA")),
      ),
      builder: (result, {fetchMore, refetch}) {
        if (result.isLoading) return Image.asset("images/KitsuQSearching.gif");
        if (result.hasException) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Error: ${result.exception.toString()}",
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final List animeList = result.data?['Page']?['media'] ?? [];

        if (animeList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No anime found.", style: TextStyle(color: Colors.white70)),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: animeList.length,
          itemBuilder: (context, index) {
            final anime = animeList[index];
            return KisuQAnimeCard(anime: anime , isRomaji: isRomaji);
          },
        );
      },
    );
  }
}

class KisuQAnimeCard extends StatelessWidget {
  final Map anime;
  final bool isRomaji;
  const KisuQAnimeCard({super.key, required this.anime , required this.isRomaji});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white10,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                anime['coverImage']['large'],
                width: 100,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRomaji ? anime['title']['romaji'] ?? anime['title']['english'] ?? "No Title": anime['title']['english'] ?? anime['title']['romaji'] ?? "No Title",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      if (anime['startDate'] != null)
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              "${anime['startDate']['year']}-${anime['startDate']['month']??"1".toString().padLeft(2, '0')}-${anime['startDate']['day']??"1".toString().padLeft(2, '0')}",
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      const SizedBox(width: 12),
                      if (anime['status'] != null)
                        Row(
                          children: [
                            const Icon(Icons.tv, size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              anime['status'].toString().replaceAll('_', ' '),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (anime['description'] != null)
                    Text(
                      anime['description']
                          .replaceAll(RegExp(r'<[^>]*>'), '')
                          .replaceAll('&quot;', '"')
                          .replaceAll('&rsquo;', "'")
                          .replaceAll('&mdash;', '—')
                          .replaceAll('&amp;', '&')
                          .replaceAll('&hellip;', '...')
                          .trim(),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),

                  const SizedBox(height: 10),

                  if (anime['averageScore'] != null)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          "${anime['averageScore']} / 100",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),

                  if (anime['episodes'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.video_library, size: 16, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            "Episodes: ${anime['episodes']}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  if (anime['chapters'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.library_books_outlined, size: 16, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            "Chapters: ${anime['chapters']}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




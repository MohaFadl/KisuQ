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

class KisuQAnimeCard extends StatefulWidget {
  final Map anime;
  final bool isRomaji;

  const KisuQAnimeCard({super.key, required this.anime, required this.isRomaji});

  @override
  _KisuQAnimeCardState createState() => _KisuQAnimeCardState();
}

class _KisuQAnimeCardState extends State<KisuQAnimeCard> {
  bool _isPressed = false;

  String get cleanedDescription {
    return widget.anime['description']
        ?.replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&rsquo;', "'")
        .replaceAll('&mdash;', '—')
        .replaceAll('&amp;', '&')
        .replaceAll('&hellip;', '...')
        .trim() ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: _isPressed ? 1.02 : 1.0,
      child: Card(
        color: Colors.white10,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onHighlightChanged: (isHighlighted) {
            setState(() {
              _isPressed = isHighlighted;
            });
          },
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.anime['coverImage']['large'],
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
                        widget.isRomaji
                            ? widget.anime['title']['romaji'] ?? widget.anime['title']['english'] ?? "No Title"
                            : widget.anime['title']['english'] ?? widget.anime['title']['romaji'] ?? "No Title",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (widget.anime['startDate'] != null)
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  "${widget.anime['startDate']['year']}-${widget.anime['startDate']['month']?.toString().padLeft(2, '0') ?? '01'}-${widget.anime['startDate']['day']?.toString().padLeft(2, '0') ?? '01'}",
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          const SizedBox(width: 12),
                          if (widget.anime['status'] != null)
                            Row(
                              children: [
                                const Icon(Icons.tv, size: 14, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  widget.anime['status'].toString().replaceAll('_', ' '),
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (widget.anime['description'] != null)
                        Text(
                          cleanedDescription,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (widget.anime['averageScore'] != null)
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  "${widget.anime['averageScore']} / 100",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (widget.anime['episodes'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.video_library, size: 16, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                "Episodes: ${widget.anime['episodes']}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      if (widget.anime['chapters'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.library_books_outlined, size: 16, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                "Chapters: ${widget.anime['chapters']}",
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
        ),
      ),
    );
  }
}







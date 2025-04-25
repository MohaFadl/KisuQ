import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../APIServices/GraphQLPain.dart';
import '../AnimeInfoPage/KitsuQAnimeDetails.dart';



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
  final Map<String, dynamic> anime;
  final bool isRomaji;

  const KisuQAnimeCard({
    Key? key,
    required this.anime,
    required this.isRomaji,
  }) : super(key: key);

  @override
  State<KisuQAnimeCard> createState() => _KisuQAnimeCardState();
}

class _KisuQAnimeCardState extends State<KisuQAnimeCard> {
  static const _bgColor = Color(0xff202020);
  static const _cardColor = Color(0xff2a2a2a);
  static const _highlightColor = Color(0xff3a3a3a);
  bool _isHovered = false;

  String get cleanedDescription {
    return widget.anime['description']
        ?.replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&rsquo;', "'")
        .replaceAll('&mdash;', '—')
        .replaceAll('&amp;', '&')
        .replaceAll('&hellip;', '...')
        .trim() ??
        'No description available';
  }

  String get formattedDate {
    final start = widget.anime['startDate'];
    if (start == null) return 'Unknown';
    final year = start['year']?.toString() ?? '1';
    final month = start['month']?.toString().padLeft(2, '0') ?? '01';
    final day = start['day']?.toString().padLeft(2, '0') ?? '01';
    return '$year-$month-$day';
  }

  String get seasonInfo {
    final s = widget.anime['season'];
    final y = widget.anime['seasonYear'];
    return (s != null && y != null)
        ? '${s[0].toUpperCase()}${s.substring(1)} $y'
        : '';
  }

  @override
  Widget build(BuildContext context) {
    final anime = widget.anime;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
        transformAlignment: Alignment.center,
        child: Card(
          color: _cardColor,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => Scaffold(
                    backgroundColor: _bgColor,
                    body: KitsuQAnimeDetails(
                      anime: anime,
                      isRomaji: widget.isRomaji,
                    ),
                  ),
                  transitionsBuilder: (_, animation, __, child) {
                    return ScaleTransition(
                      scale: Tween(begin: 0.9, end: 1.0).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                ),
              );
            },
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: _highlightColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'cover-${anime['id']}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        anime['coverImage']?['large'] ?? '',
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : Container(
                          width: 120,
                          height: 180,
                          color: Colors.grey[900],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorBuilder: (_, __, ___) => Container(
                          width: 120,
                          height: 180,
                          color: Colors.grey[900],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'title-${anime['id']}',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              widget.isRomaji
                                  ? widget.anime['title']['romaji'] ?? widget.anime['title']['english'] ?? "No Title"
                                  : widget.anime['title']['english'] ?? widget.anime['title']['romaji'] ?? "No Title",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _buildMetadataItem(Icons.calendar_month, formattedDate),
                            if (anime['status'] != null)
                              _buildMetadataItem(Icons.tv, anime['status'].toString().replaceAll('_', ' ')),
                            if (seasonInfo.isNotEmpty) _buildMetadataItem(Icons.event, seasonInfo),
                            if (anime['format'] != null)
                              _buildMetadataItem(Icons.category, anime['format']),
                            if (anime['studios']?['nodes']?.isNotEmpty ?? false)
                              _buildMetadataItem(Icons.business, anime['studios']['nodes'][0]['name']),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (anime['episodes'] != null)
                              _buildMediaInfo(Icons.movie, '${anime['episodes']} Ep'),
                            if (anime['chapters'] != null)
                              _buildMediaInfo(Icons.menu_book, '${anime['chapters']} Ch'),
                            if (anime['volumes'] != null)
                              _buildMediaInfo(Icons.library_books, '${anime['volumes']} Vol'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (anime['genres']?.isNotEmpty ?? false)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: anime['genres']!
                                .take(3)
                                .map<Widget>(
                                  (genre) => Chip(
                                label: Text(genre, style: const TextStyle(fontSize: 12, color: Colors.white)),
                                backgroundColor: Colors.grey[800],
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                                .toList(),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          cleanedDescription,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        if (anime['averageScore'] != null)
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                "${anime['averageScore']}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildMediaInfo(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(right: 12),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    ),
  );
}









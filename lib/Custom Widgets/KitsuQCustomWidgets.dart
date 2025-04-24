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
        .trim() ?? 'No description available';
  }

  String get formattedDate {
    if (widget.anime['startDate'] == null) return 'Unknown date';
    final year = widget.anime['startDate']['year']?.toString() ?? '1';
    final month = widget.anime['startDate']['month']?.toString().padLeft(2, '0') ?? '01';
    final day = widget.anime['startDate']['day']?.toString().padLeft(2, '0') ?? '01';
    return '$year-$month-$day';
  }

  String get seasonInfo {
    if (widget.anime['season'] == null || widget.anime['seasonYear'] == null) return '';
    final season = widget.anime['season'].toString().toLowerCase();
    return '${season[0].toUpperCase()}${season.substring(1)} ${widget.anime['seasonYear']}';
  }

  @override
  Widget build(BuildContext context) {
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return Scaffold(
                      backgroundColor: _bgColor,
                      body: KitsuQAnimeDetails(
                        anime: widget.anime,
                        isRomaji: widget.isRomaji,
                      ),
                    );
                  },
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);
                    var scaleAnimation = Tween(begin: 0.9, end: 1.0).animate(animation);

                    return ScaleTransition(
                      scale: scaleAnimation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
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
                    tag: 'cover-${widget.anime['id']}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.anime['coverImage']['large'] ?? '',
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 120,
                            height: 180,
                            color: Colors.grey[900],
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.grey[700]),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 180,
                            color: Colors.grey[900],
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'title-${widget.anime['id']}',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              widget.isRomaji
                                  ? widget.anime['title']['romaji'] ?? widget.anime['title']['english'] ?? "No Title"
                                  : widget.anime['title']['english'] ?? widget.anime['title']['romaji'] ?? "No Title",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
                            if (widget.anime['startDate'] != null)
                              _buildMetadataItem(Icons.calendar_month, formattedDate),
                            if (widget.anime['status'] != null)
                              _buildMetadataItem(Icons.tv, widget.anime['status'].toString().replaceAll('_', ' ')),
                            if (seasonInfo.isNotEmpty)
                              _buildMetadataItem(Icons.event, seasonInfo),
                            if (widget.anime['studios']?['nodes'] != null && widget.anime['studios']['nodes'].isNotEmpty)
                              _buildMetadataItem(Icons.theaters, widget.anime['studios']['nodes'][0]['name']),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          children: [
                            if (widget.anime['episodes'] != null)
                              _buildMediaInfo(Icons.movie, '${widget.anime['episodes']} Ep'),
                            if (widget.anime['chapters'] != null)
                              _buildMediaInfo(Icons.menu_book, '${widget.anime['chapters']} Ch'),
                            const SizedBox(width: 8),
                            if (widget.anime['chapters'] != null && widget.anime['volumes'] != null)
                              if (widget.anime['volumes'] != null)
                                _buildMediaInfo(Icons.library_books, '${widget.anime['volumes']} Vol'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (widget.anime['genres']?.isNotEmpty ?? false)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: widget.anime['genres']!
                                .take(3)
                                .map<Widget>((genre) => Chip(
                              label: Text(
                                genre,
                                style: const TextStyle(fontSize: 12, color: Colors.white),
                              ),
                              backgroundColor: Colors.grey[800],
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ))
                                .toList(),
                          ),
                        const SizedBox(height: 12),
                        if (widget.anime['description'] != null)
                          Text(
                            cleanedDescription,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (widget.anime['averageScore'] != null)
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${widget.anime['averageScore']}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
        Text(
          text,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMediaInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}









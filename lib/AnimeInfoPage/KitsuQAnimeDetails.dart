import 'package:flutter/material.dart';
import 'dart:ui';

class KitsuQAnimeDetails extends StatelessWidget {
  final Map anime;
  final bool isRomaji;

  const KitsuQAnimeDetails({super.key, required this.anime, required this.isRomaji});

  String get cleanedDescription {
    return anime['description']
        ?.replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&rsquo;', "'")
        .replaceAll('&mdash;', '—')
        .replaceAll('&amp;', '&')
        .replaceAll('&hellip;', '...')
        .trim() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = anime['coverImage']['large'] ?? anime['bannerImage'] ?? '';
    final title = isRomaji
        ? anime['title']['romaji'] ?? anime['title']['english'] ?? "No Title"
        : anime['title']['english'] ?? anime['title']['romaji'] ?? "No Title";

    final isAnime = anime['type'] == 'ANIME'; // Check if the media is anime

    return Scaffold(
      backgroundColor: const Color(0xff202020),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // BACKGROUND COVER
          Positioned.fill(
            child: Image.network(
              coverUrl,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),

          // MAIN CONTENT
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: kToolbarHeight + 40, bottom: 20),
            child: Column(
              children: [
                // POSTER IMAGE
                Hero(
                  tag: anime['id'] ?? coverUrl,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      coverUrl,
                      width: 200,
                      height: 280,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // DETAILS CARD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    opacity: 1,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cleanedDescription,
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 16),

                          // Display start date
                          if (anime['startDate'] != null)
                            _InfoRow(
                              icon: Icons.calendar_today,
                              label:
                              "Start Date: ${anime['startDate']['year']}-${anime['startDate']['month']?.toString().padLeft(2, '0') ?? '01'}-${anime['startDate']['day']?.toString().padLeft(2, '0') ?? '01'}",
                            ),

                          // Status of anime/manga
                          if (anime['status'] != null)
                            _InfoRow(
                              icon: Icons.tv,
                              label:
                              "Status: ${anime['status'].toString().replaceAll('_', ' ')}",
                            ),

                          // Average score
                          if (anime['averageScore'] != null)
                            _InfoRow(
                              icon: Icons.star,
                              label: "Average Score: ${anime['averageScore']} / 100",
                            ),

                          // Genre list
                          if (anime['genres'] != null && anime['genres'].isNotEmpty)
                            _InfoRow(
                              icon: Icons.category,
                              label: "Genres: ${anime['genres'].join(', ')}",
                            ),

                          // Display episode count if it's anime, chapters/volumes if it's manga
                          if (isAnime && anime['episodes'] != null)
                            _InfoRow(
                              icon: Icons.video_library,
                              label: "Episodes: ${anime['episodes']}",
                            ),
                          if (!isAnime && anime['chapters'] != null)
                            _InfoRow(
                              icon: Icons.library_books,
                              label: "Chapters: ${anime['chapters']}",
                            ),
                          if (!isAnime && anime['volumes'] != null)
                            _InfoRow(
                              icon: Icons.library_books,
                              label: "Volumes: ${anime['volumes']}",
                            ),

                          // Studio Info
                          if (anime['studios'] != null && anime['studios']['nodes'].isNotEmpty)
                            _InfoRow(
                              icon: Icons.business,
                              label: "Studio: ${anime['studios']['nodes'][0]['name']}",
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Recommended anime/manga
                if (anime['recommendations'] != null && anime['recommendations']['nodes'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          "You might also like",
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        _buildRecommendationList(anime['recommendations']['nodes']),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationList(List recommendations) {
    return Column(
      children: recommendations.map<Widget>((recommendation) {
        final media = recommendation['mediaRecommendation'];
        return GestureDetector(
          onTap: () {
            // Navigate to recommended anime details
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    media['coverImage']['large'],
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  media['title']['romaji'] ?? media['title']['english'] ?? "No Title",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  "Score: ${media['averageScore'] ?? 'N/A'}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  "Genres: ${media['genres']?.join(', ') ?? 'N/A'}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

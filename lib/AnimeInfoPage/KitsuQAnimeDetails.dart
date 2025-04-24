import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: Color(0xff202020),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xff202020),
        title: Text(
          style: TextStyle(color: Colors.white),
          isRomaji
              ? anime['title']['romaji'] ?? anime['title']['english'] ?? "No Title"
              : anime['title']['english'] ?? anime['title']['romaji'] ?? "No Title",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  anime['coverImage']['large'],
                  width: 200,
                  height: 280,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              cleanedDescription,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (anime['startDate'] != null)
              _InfoRow(
                icon: Icons.calendar_today,
                label:
                "Start Date: ${anime['startDate']['year']}-${anime['startDate']['month']?.toString().padLeft(2, '0') ?? '01'}-${anime['startDate']['day']?.toString().padLeft(2, '0') ?? '01'}",
              ),
            if (anime['status'] != null)
              _InfoRow(
                icon: Icons.tv,
                label: "Status: ${anime['status'].toString().replaceAll('_', ' ')}",
              ),
            if (anime['averageScore'] != null)
              _InfoRow(
                icon: Icons.star,
                label: "Average Score: ${anime['averageScore']} / 100",
              ),
            if (anime['episodes'] != null)
              _InfoRow(
                icon: Icons.video_library,
                label: "Episodes: ${anime['episodes']}",
              ),
            if (anime['chapters'] != null)
              _InfoRow(
                icon: Icons.library_books,
                label: "Chapters: ${anime['chapters']}",
              ),
          ],
        ),
      ),
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

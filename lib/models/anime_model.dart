class AnimeModel {
  final int id;
  final String title;
  final String coverImageUrl;
  final int? averageScore;
  final String? description;
  final List<String>? genres;
  
  // --- Data Baru untuk Detail Lengkap ---
  final String? status;
  final int? episodes;
  final String? season;
  final int? seasonYear;
  final String? trailerUrl; // URL YouTube
  final List<CharacterModel>? characters;
  final List<AnimeModel>? recommendations;

  AnimeModel({
    required this.id,
    required this.title,
    required this.coverImageUrl,
    this.averageScore,
    this.description,
    this.genres,
    this.status,
    this.episodes,
    this.season,
    this.seasonYear,
    this.trailerUrl,
    this.characters,
    this.recommendations,
  });

  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    // Helper untuk trailer
    String? trailer;
    if (json['trailer'] != null && json['trailer']['site'] == 'youtube') {
      trailer = 'https://www.youtube.com/watch?v=${json['trailer']['id']}';
    }

    // Helper untuk Karakter
    List<CharacterModel>? chars;
    if (json['characters'] != null && json['characters']['nodes'] != null) {
      chars = (json['characters']['nodes'] as List)
          .map((c) => CharacterModel.fromJson(c))
          .toList();
    }

    // Helper untuk Rekomendasi
    List<AnimeModel>? recs;
    if (json['recommendations'] != null && json['recommendations']['nodes'] != null) {
      recs = (json['recommendations']['nodes'] as List)
          .where((r) => r['mediaRecommendation'] != null) // Filter yang null
          .map((r) => AnimeModel.fromJson(r['mediaRecommendation']))
          .toList();
    }

    return AnimeModel(
      id: json['id'],
      title: json['title']['romaji'] ?? json['title']['english'] ?? 'No Title',
      coverImageUrl: json['coverImage']['large'] ?? '',
      averageScore: json['averageScore'],
      description: json['description'],
      genres: json['genres'] != null
          ? List<String>.from(json['genres'].map((g) => g.toString()))
          : [],
      status: json['status'],
      episodes: json['episodes'],
      season: json['season'],
      seasonYear: json['seasonYear'],
      trailerUrl: trailer,
      characters: chars,
      recommendations: recs,
    );
  }
}

class CharacterModel {
  final String name;
  final String imageUrl;

  CharacterModel({required this.name, required this.imageUrl});

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      name: json['name']['full'],
      imageUrl: json['image']['large'] ?? '',
    );
  }
}
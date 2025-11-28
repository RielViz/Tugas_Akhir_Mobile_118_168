// --------------------------------
// lib/data/models/anime_model.dart
// --------------------------------

class AnimeModel {
  final int id;
  final String title;
  final String coverImageUrl;
  final int? averageScore;
  
  // --- FIELD BARU (Nullable) ---
  final String? description;
  final List<String>? genres;

  AnimeModel({
    required this.id,
    required this.title,
    required this.coverImageUrl,
    this.averageScore,
    this.description, 
    this.genres,   
  });

  // Factory constructor untuk mengubah JSON (Map) dari API menjadi Objek AnimeModel
  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    
    // Konversi 'genres' dari List<dynamic> ke List<String>
    List<String>? genreList;
    if (json['genres'] != null) {
      genreList = List<String>.from(json['genres'].map((g) => g.toString()));
    }

    return AnimeModel(
      id: json['id'],
      title: json['title']['romaji'] ?? json['title']['english'] ?? 'No Title',
      coverImageUrl: json['coverImage']['large'] ?? '',
      averageScore: json['averageScore'],
      
      // --- Parsing Data BARU ---
      description: json['description'],
      genres: genreList,          
    );
  }
}
// -----------------------------------------
// lib/models/my_anime_entry_model.dart
// -----------------------------------------
import 'package:hive/hive.dart';

part 'my_anime_entry_model.g.dart';

@HiveType(typeId: 2)
class MyAnimeEntryModel extends HiveObject {
  @HiveField(0)
  final int animeId; // ID tetap final (tidak boleh berubah)

  @HiveField(1)
  final String title; // Judul tetap final

  @HiveField(2)
  final String coverImageUrl; // Gambar tetap final

  @HiveField(3)
  String status; // <--- HAPUS 'final' DISINI

  @HiveField(4)
  int? userScore; // <--- HAPUS 'final' DISINI

  @HiveField(5)
  int episodesWatched; 

  @HiveField(6)
  DateTime? startDate; // <--- HAPUS 'final' DISINI

  @HiveField(7)
  DateTime? finishDate; // <--- HAPUS 'final' DISINI

  @HiveField(8)
  int totalRewatches; // <--- HAPUS 'final' DISINI

  @HiveField(9)
  String notes; // <--- HAPUS 'final' DISINI

  MyAnimeEntryModel({
    required this.animeId,
    required this.title,
    required this.coverImageUrl,
    required this.status,
    this.userScore,
    this.episodesWatched = 0,
    this.startDate,
    this.finishDate,
    this.totalRewatches = 0,
    this.notes = '',
  });
}
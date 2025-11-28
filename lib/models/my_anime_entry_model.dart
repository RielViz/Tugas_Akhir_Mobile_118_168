// -----------------------------------------
// lib/data/models/my_anime_entry_model.dart
// -----------------------------------------
import 'package:hive/hive.dart';

part 'my_anime_entry_model.g.dart';

@HiveType(typeId: 2)
class MyAnimeEntryModel extends HiveObject {
  @HiveField(0)
  final int animeId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String coverImageUrl;

  @HiveField(3)
  final String status;

  @HiveField(4)
  final int? userScore;

  MyAnimeEntryModel({
    required this.animeId,
    required this.title,
    required this.coverImageUrl,
    required this.status,
    this.userScore,
  });
}
// ---------------------------------------------------
// lib/screens/anime_detail_screen.dart
// ---------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // Pastikan package intl sudah terinstall
import 'package:url_launcher/url_launcher.dart';
import '../models/anime_model.dart';
import '../models/my_anime_entry_model.dart';
import '../repositories/anime_repository.dart';
import '../repositories/my_list_repository.dart';
import '../logic/anime_detail_bloc.dart';
import '../logic/my_list_bloc.dart' as my_list;

class AnimeDetailScreen extends StatelessWidget {
  final int animeId;
  const AnimeDetailScreen({super.key, required this.animeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnimeDetailBloc(
        animeRepository: context.read<AnimeRepository>(),
        myListRepository: context.read<MyListRepository>(),
      )..add(LoadAnimeDetail(animeId: animeId)),
      child: const AnimeDetailView(),
    );
  }
}

class AnimeDetailView extends StatelessWidget {
  const AnimeDetailView({super.key});

  Future<void> _launchTrailer(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch trailer");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AnimeDetailBloc, AnimeDetailState>(
        builder: (context, state) {
          if (state is AnimeDetailLoading)
            return const Center(child: CircularProgressIndicator());

          if (state is AnimeDetailLoaded) {
            final anime = state.anime;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(anime.title,
                        style: const TextStyle(
                            fontSize: 16, shadows: [Shadow(blurRadius: 4)])),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(anime.coverImageUrl, fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.9)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderInfo(anime),
                          const SizedBox(height: 20),
                          _buildEditorButton(context, state),
                          const SizedBox(height: 24),
                          const Text("Sinopsis",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            anime.description
                                    ?.replaceAll(RegExp(r'<[^>]*>'), '') ??
                                "Tidak ada deskripsi.",
                            style: const TextStyle(
                                height: 1.5, color: Colors.white70),
                          ),
                          const SizedBox(height: 24),
                          if (anime.characters != null &&
                              anime.characters!.isNotEmpty)
                            _buildCharacterList(anime.characters!),
                          const SizedBox(height: 24),
                          if (anime.recommendations != null &&
                              anime.recommendations!.isNotEmpty)
                            _buildRecommendations(
                                context, anime.recommendations!),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            );
          }
          return const Center(child: Text("Gagal memuat detail"));
        },
      ),
    );
  }

  Widget _buildHeaderInfo(AnimeModel anime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${anime.season ?? '?'} ${anime.seasonYear ?? ''}",
                style: const TextStyle(
                    color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
                "${anime.episodes ?? '?'} Episode • ${anime.status ?? 'Unknown'}",
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        if (anime.trailerUrl != null)
          OutlinedButton.icon(
            onPressed: () => _launchTrailer(anime.trailerUrl!),
            icon: const Icon(Icons.play_circle_fill, color: Colors.redAccent),
            label: const Text("Trailer", style: TextStyle(color: Colors.white)),
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent)),
          ),
      ],
    );
  }

  Widget _buildEditorButton(BuildContext context, AnimeDetailLoaded state) {
    final bool isAdded = state.isInMyList;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isAdded ? Colors.green : Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => _showEditorModal(context, state.anime, state.entry),
        child: Text(
          isAdded ? "Edit List" : "Add to List",
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  // --- MODAL EDITOR DENGAN DATE PICKER ---
  void _showEditorModal(
      BuildContext context, AnimeModel anime, MyAnimeEntryModel? entry) {
    final detailBloc = context.read<AnimeDetailBloc>();
    final myListBloc = context.read<my_list.MyListBloc>();

    String currentStatus = entry?.status ?? 'Planning';
    int currentScore = entry?.userScore ?? 0;
    int currentProgress = entry?.episodesWatched ?? 0;
    DateTime? startDate = entry?.startDate;
    DateTime? finishDate = entry?.finishDate;
    int totalRewatches = entry?.totalRewatches ?? 0;
    String notes = entry?.notes ?? '';
    int maxEpisodes = anime.episodes ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF151F2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            // FUNGSI PICK DATE
            Future<void> pickDate(bool isStart) async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: isStart
                    ? (startDate ?? DateTime.now())
                    : (finishDate ?? DateTime.now()),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                        surface: Color(0xFF1F2937),
                        onSurface: Colors.white,
                      ),
                      dialogBackgroundColor: const Color(0xFF151F2E),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  if (isStart)
                    startDate = picked;
                  else
                    finishDate = picked;
                });
              }
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(anime.coverImageUrl,
                            width: 60, height: 85, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(anime.title,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 2),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (entry != null)
                                  TextButton(
                                    onPressed: () {
                                      detailBloc.add(
                                          RemoveFromMyList(animeId: anime.id));
                                      myListBloc.add(my_list.RemoveFromMyList(
                                          animeId: anime.id));
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Delete",
                                        style:
                                            TextStyle(color: Colors.redAccent)),
                                  ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent),
                                  onPressed: () {
                                    detailBloc.add(SaveAnimeEntry(
                                      animeId: anime.id,
                                      title: anime.title,
                                      coverImageUrl: anime.coverImageUrl,
                                      status: currentStatus,
                                      progress: currentProgress,
                                      score: currentScore,
                                      startDate: startDate,
                                      finishDate: finishDate,
                                      totalRewatches: totalRewatches,
                                      notes: notes,
                                    ));

                                    myListBloc.add(my_list.AddOrUpdateEntry(
                                        entry: MyAnimeEntryModel(
                                      animeId: anime.id,
                                      title: anime.title,
                                      coverImageUrl: anime.coverImageUrl,
                                      status: currentStatus,
                                      episodesWatched: currentProgress,
                                      userScore: currentScore,
                                      startDate: startDate,
                                      finishDate: finishDate,
                                      totalRewatches: totalRewatches,
                                      notes: notes,
                                    )));
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Save",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 30),

                  // INPUT FORM
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildInputContainer(
                                label: "Status",
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: currentStatus,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF1F2937),
                                    items: [
                                      'Planning',
                                      'Watching',
                                      'Completed',
                                      'Dropped',
                                      'Paused'
                                    ]
                                        .map((s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white))))
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => currentStatus = val!),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildInputContainer(
                                label: "Score",
                                child: TextFormField(
                                  initialValue: currentScore.toString(),
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                      border: InputBorder.none, isDense: true),
                                  onChanged: (val) =>
                                      currentScore = int.tryParse(val) ?? 0,
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildInputContainer(
                                label: "Progress",
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        key: ValueKey(currentProgress),
                                        initialValue:
                                            currentProgress.toString(),
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            isDense: true),
                                        onChanged: (val) => currentProgress =
                                            int.tryParse(val) ?? 0,
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.add,
                                          size: 16, color: Colors.grey),
                                      onPressed: (maxEpisodes == 0 ||
                                              currentProgress < maxEpisodes)
                                          ? () =>
                                              setState(() => currentProgress++)
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildInputContainer(
                                label: "Start Date",
                                child: GestureDetector(
                                  onTap: () => pickDate(true),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          startDate != null
                                              ? DateFormat('yyyy-MM-dd')
                                                  .format(startDate!)
                                              : "Set Date",
                                          style: TextStyle(
                                              color: startDate != null
                                                  ? Colors.white
                                                  : Colors.grey)),
                                      const Icon(Icons.calendar_today,
                                          size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildInputContainer(
                                label: "Rewatches",
                                child: TextFormField(
                                  initialValue: totalRewatches.toString(),
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                      border: InputBorder.none, isDense: true),
                                  onChanged: (val) =>
                                      totalRewatches = int.tryParse(val) ?? 0,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildInputContainer(
                                label: "Finish Date",
                                child: GestureDetector(
                                  onTap: () => pickDate(false),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          finishDate != null
                                              ? DateFormat('yyyy-MM-dd')
                                                  .format(finishDate!)
                                              : "Set Date",
                                          style: TextStyle(
                                              color: finishDate != null
                                                  ? Colors.white
                                                  : Colors.grey)),
                                      const Icon(Icons.calendar_today,
                                          size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(flex: 2, child: SizedBox()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Notes",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF1F2937),
                                    borderRadius: BorderRadius.circular(6)),
                                child: TextFormField(
                                  initialValue: notes,
                                  maxLines: 3,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration.collapsed(
                                      hintText: "Add notes..."),
                                  onChanged: (val) => notes = val,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputContainer({required String label, required Widget child}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 6),
          Container(
            height: 45,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(6)),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterList(List<CharacterModel> chars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Characters",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: chars.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final char = chars[index];
              return SizedBox(
                width: 80,
                child: Column(
                  children: [
                    CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(char.imageUrl)),
                    const SizedBox(height: 8),
                    Text(char.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(BuildContext context, List<AnimeModel> recs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recommendations",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final rec = recs[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AnimeDetailScreen(animeId: rec.id))),
                child: SizedBox(
                  width: 110,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(rec.coverImageUrl,
                              height: 140, width: 110, fit: BoxFit.cover)),
                      const SizedBox(height: 6),
                      Text(rec.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

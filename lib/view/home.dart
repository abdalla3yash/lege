import "package:flutter/material.dart";
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'player.dart';

class SongHomeScreen extends StatefulWidget {
  const SongHomeScreen({super.key});

  @override
  State<SongHomeScreen> createState() => SongHomeScreenState();
}

class SongHomeScreenState extends State<SongHomeScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<List<SongModel>> getSongs() {
    return _audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true);
  }

  @override
  void initState() {
    super.initState();
    permissionHandler();
  }

  void permissionHandler() {
    Permission.storage.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lege"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 195, 214, 22),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: FutureBuilder<List<SongModel>>(
        future: getSongs(),
        builder: ((context, item) {
          if (item.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (item.data!.isEmpty) {
            return const Center(
              child: Text("No Songs Found!!"),
            );
          }
          return ListView.builder(
            itemBuilder: (context, index) => ListTile(
              leading: const Icon(
                Icons.music_note_rounded,
                color: Color.fromARGB(255, 195, 214, 22),
              ),
              title: Text(item.data![index].displayNameWOExt),
              subtitle: Text("${item.data![index].artist}"),
              trailing: const Icon(Icons.more_horiz),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerNow(
                        songModel: item.data![index],
                        audioPlayer: _audioPlayer),
                  ),
                );
                // playSong(item.data![index].uri);
              },
            ),
            itemCount: item.data!.length,
          );
        }),
      ),
    );
  }
}

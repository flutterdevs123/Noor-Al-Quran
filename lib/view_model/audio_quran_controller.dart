import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import '../models/qari_model.dart';

class AudioQuranController extends GetxController {
  final AudioPlayer player = AudioPlayer();
  final Dio _dio = Dio();

  final Rx<QariModel> selectedQari = QuranAudioData.top20Qaris.first.obs;
  final Rxn<SurahMeta> currentSurah = Rxn<SurahMeta>();
  final RxBool isPlaying = false.obs;
  final RxBool isBuffering = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final RxDouble playbackSpeed = 1.0.obs;
  final RxString searchQuery = ''.obs;

  // Keys formatted as: '${qariId}_${surahNumber}'
  final RxSet<String> downloadedKeys = <String>{}.obs;
  final RxMap<String, double> downloadProgress = <String, double>{}.obs;

  String? _loadedQariId;
  late Directory _audioRootDir;

  @override
  void onInit() {
    super.onInit();
    _initStorageAndListeners();
  }

  Future<void> _initStorageAndListeners() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    _audioRootDir = Directory('${appDir.path}/quran_audio');
    if (!await _audioRootDir.exists()) {
      await _audioRootDir.create(recursive: true);
    }

    await _scanDownloadedFiles(selectedQari.value.id);

    // Sync playing & buffering state
    player.playerStateStream.listen((PlayerState state) {
      isPlaying.value = state.playing;
      isBuffering.value = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
    });

    // Sync current Surah when playlist advances automatically or via Notification Next/Prev
    player.currentIndexStream.listen((int? index) {
      if (index != null && index >= 0 && index < QuranAudioData.allSurahs.length) {
        currentSurah.value = QuranAudioData.allSurahs[index];
      }
    });

    // Sync seekbar position & total duration
    player.positionStream.listen((Duration pos) => position.value = pos);
    player.durationStream.listen((Duration? dur) {
      if (dur != null) duration.value = dur;
    });
  }

  String _key(String qariId, int surahNumber) => '${qariId}_$surahNumber';

  File _getLocalFile(String qariId, int surahNumber) {
    final String padded = surahNumber.toString().padLeft(3, '0');
    return File('${_audioRootDir.path}/$qariId/$padded.mp3');
  }

  Future<void> _scanDownloadedFiles(String qariId) async {
    final Directory qariDir = Directory('${_audioRootDir.path}/$qariId');
    if (!await qariDir.exists()) return;

    final List<FileSystemEntity> files = qariDir.listSync();
    for (final FileSystemEntity entity in files) {
      if (entity is File && entity.path.endsWith('.mp3')) {
        final String fileName = entity.uri.pathSegments.last.replaceAll('.mp3', '');
        final int? surahNum = int.tryParse(fileName);
        if (surahNum != null && await entity.length() > 1024) {
          downloadedKeys.add(_key(qariId, surahNum));
        }
      }
    }
  }

  bool isSurahDownloaded(int surahNumber) {
    return downloadedKeys.contains(_key(selectedQari.value.id, surahNumber));
  }

  double? getDownloadProgress(int surahNumber) {
    return downloadProgress[_key(selectedQari.value.id, surahNumber)];
  }

  List<SurahMeta> get filteredSurahs {
    final String q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return QuranAudioData.allSurahs;
    return QuranAudioData.allSurahs.where((SurahMeta s) {
      return s.englishName.toLowerCase().contains(q) ||
          s.arabicName.contains(q) ||
          s.number.toString() == q;
    }).toList();
  }

  Future<void> selectQari(QariModel qari) async {
    if (selectedQari.value.id == qari.id) return;
    selectedQari.value = qari;
    await _scanDownloadedFiles(qari.id);

    // If a surah was playing, switch to the newly selected Qari seamlessly
    if (currentSurah.value != null) {
      await playSurah(currentSurah.value!.number);
    }
  }

  Future<void> playSurah(int surahNumber) async {
    final QariModel qari = selectedQari.value;
    final int targetIndex = surahNumber - 1;
    currentSurah.value = QuranAudioData.allSurahs[targetIndex];

    try {
      // Rebuild 114-Surah playlist if Qari changed or not loaded yet
      if (_loadedQariId != qari.id) {
        final List<AudioSource> sources = <AudioSource>[];
        for (final SurahMeta surah in QuranAudioData.allSurahs) {
          final File localFile = _getLocalFile(qari.id, surah.number);
          final MediaItem tag = MediaItem(
            id: '${qari.id}_${surah.number}',
            album: 'Noor-Al-Quran • ${qari.style}',
            title: '${surah.number}. Surah ${surah.englishName} (${surah.arabicName})',
            artist: qari.name,
          );

          if (await localFile.exists()) {
            sources.add(AudioSource.file(localFile.path, tag: tag));
          } else {
            sources.add(AudioSource.uri(Uri.parse(qari.getSurahUrl(surah.number)), tag: tag));
          }
        }

        final ConcatenatingAudioSource playlist = ConcatenatingAudioSource(
          useLazyPreparation: true,
          children: sources,
        );

        await player.setAudioSource(playlist, initialIndex: targetIndex);
        _loadedQariId = qari.id;
      } else {
        await player.seek(Duration.zero, index: targetIndex);
      }

      await player.play();
    } catch (e) {
      Get.snackbar(
        'Playback Error',
        'Internet connection check karein ya pehle Surah download karein.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> togglePlayPause() async {
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> playNext() async {
    if (player.hasNext) {
      await player.seekToNext();
    }
  }

  Future<void> playPrevious() async {
    if (player.hasPrevious) {
      await player.seekToPrevious();
    }
  }

  Future<void> seekTo(Duration target) async {
    await player.seek(target);
  }

  Future<void> cycleSpeed() async {
    const List<double> speeds = <double>[1.0, 1.25, 1.5, 0.75];
    final int nextIdx = (speeds.indexOf(playbackSpeed.value) + 1) % speeds.length;
    playbackSpeed.value = speeds[nextIdx];
    await player.setSpeed(playbackSpeed.value);
  }

  Future<void> downloadSurah(SurahMeta surah) async {
    final QariModel qari = selectedQari.value;
    final String key = _key(qari.id, surah.number);
    if (downloadProgress.containsKey(key) || downloadedKeys.contains(key)) return;

    final Directory qariDir = Directory('${_audioRootDir.path}/${qari.id}');
    if (!await qariDir.exists()) {
      await qariDir.create(recursive: true);
    }

    final File targetFile = _getLocalFile(qari.id, surah.number);
    final File tempFile = File('${targetFile.path}.tmp');
    downloadProgress[key] = 0.0;

    try {
      await _dio.download(
        qari.getSurahUrl(surah.number),
        tempFile.path,
        onReceiveProgress: (int received, int total) {
          if (total > 0) {
            downloadProgress[key] = received / total;
          }
        },
      );

      if (await tempFile.exists()) {
        await tempFile.rename(targetFile.path);
      }

      downloadProgress.remove(key);
      downloadedKeys.add(key);
      // Force playlist refresh on next play so it uses offline file
      if (_loadedQariId == qari.id && !player.playing) {
        _loadedQariId = null;
      }

      Get.snackbar(
        'Downloaded',
        'Surah ${surah.englishName} (${qari.name}) offline save ho gayi.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      downloadProgress.remove(key);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      Get.snackbar(
        'Download Failed',
        'Network error ki wajah se download mukammal nahi ho saka.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteDownloadedSurah(SurahMeta surah) async {
    final QariModel qari = selectedQari.value;
    final String key = _key(qari.id, surah.number);
    final File file = _getLocalFile(qari.id, surah.number);

    if (await file.exists()) {
      await file.delete();
    }
    downloadedKeys.remove(key);
    _loadedQariId = null;
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/qari_model.dart';
import '../res/responsive/responsive_extensions.dart';
import '../res/responsive/responsive_utils.dart';
import '../res/theme/app_theme.dart';
import '../view_model/audio_quran_controller.dart';

class AudioQuranScreen extends GetView<AudioQuranController> {
  const AudioQuranScreen({super.key});

  String _formatDuration(Duration d) {
    final int hours = d.inHours;
    final String minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Quran • Top 20 Qaris'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          // Horizontal Top 20 Qaris Selector
          SizedBox(
            height: 92.sz,
            child: ListView.separated(
              padding: ResponsiveUtils.symmetricPadding(
                horizontal: 14,
                vertical: 8,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: QuranAudioData.top20Qaris.length,
              separatorBuilder: (_, __) => 10.hSpace,
              itemBuilder: (BuildContext context, int index) {
                final QariModel qari = QuranAudioData.top20Qaris[index];
                return Obx(() {
                  final bool isSelected =
                      controller.selectedQari.value.id == qari.id;
                  return InkWell(
                    onTap: () => controller.selectQari(qari),
                    borderRadius: BorderRadius.circular(14.r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 185.sz,
                      padding: ResponsiveUtils.symmetricPadding(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colorScheme.primary
                            : context.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isSelected
                              ? context.colorScheme.primary
                              : context.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            qari.arabicName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? context.colorScheme.onPrimary
                                  : context.colorScheme.primary,
                            ),
                          ),
                          2.vSpace,
                          Text(
                            qari.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? context.colorScheme.onPrimary
                                  : context.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            qari.style,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: isSelected
                                  ? context.colorScheme.onPrimary
                                  .withValues(alpha: 0.8)
                                  : context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),

          // Search Surah Field
          Padding(
            padding: ResponsiveUtils.symmetricPadding(
              horizontal: 14,
              vertical: 4,
            ),
            child: TextField(
              onChanged: (String val) => controller.searchQuery.value = val,
              decoration: InputDecoration(
                hintText: 'Search Surah by name or number (e.g. Yaseen, 36)...',
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
                filled: true,
                fillColor: context.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 114 Surahs List
          Expanded(
            child: Obx(() {
              final List<SurahMeta> surahs = controller.filteredSurahs;
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(14.sz, 6.sz, 14.sz, 16.sz),
                itemCount: surahs.length,
                separatorBuilder: (_, __) => 8.vSpace,
                itemBuilder: (BuildContext context, int index) {
                  final SurahMeta surah = surahs[index];
                  return Obx(() {
                    final bool isCurrent =
                        controller.currentSurah.value?.number == surah.number;
                    final bool isDownloaded =
                    controller.isSurahDownloaded(surah.number);
                    final double? progress =
                    controller.getDownloadProgress(surah.number);

                    return Material(
                      color: isCurrent
                          ? context.colorScheme.primaryContainer
                          .withValues(alpha: 0.65)
                          : context.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14.r),
                      child: InkWell(
                        onTap: () => controller.playSurah(surah.number),
                        borderRadius: BorderRadius.circular(14.r),
                        child: Padding(
                          padding: ResponsiveUtils.symmetricPadding(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 18.r,
                                backgroundColor: isCurrent
                                    ? context.colorScheme.primary
                                    : context.colorScheme.secondaryContainer,
                                child: Text(
                                  '${surah.number}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrent
                                        ? context.colorScheme.onPrimary
                                        : context
                                        .colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                              12.hSpace,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Flexible(
                                          child: Text(
                                            surah.englishName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        if (isDownloaded) ...<Widget>[
                                          6.hSpace,
                                          Container(
                                            padding:
                                            ResponsiveUtils.symmetricPadding(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                              BorderRadius.circular(6.r),
                                            ),
                                            child: Text(
                                              'Offline',
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      '${surah.versesCount} Ayahs',
                                      style: context.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                surah.arabicName,
                                style: TextStyle(
                                  fontFamily: 'KFGQPCUthmanTahaNaskh',
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.bold,
                                  color: context.colorScheme.primary,
                                ),
                              ),
                              8.hSpace,
                              if (progress != null)
                                SizedBox(
                                  width: 32.sz,
                                  height: 32.sz,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      CircularProgressIndicator(
                                        value: progress,
                                        strokeWidth: 2.5,
                                      ),
                                      Text(
                                        '${(progress * 100).toInt()}%',
                                        style: TextStyle(
                                          fontSize: 8.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (isDownloaded)
                                IconButton(
                                  tooltip: 'Delete Offline File',
                                  onPressed: () =>
                                      controller.deleteDownloadedSurah(surah),
                                  icon: const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.green,
                                  ),
                                )
                              else
                                IconButton(
                                  tooltip: 'Download for Offline',
                                  onPressed: () =>
                                      controller.downloadSurah(surah),
                                  icon: Icon(
                                    Icons.download_for_offline_outlined,
                                    color: context.colorScheme.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),

          // Bottom Persistent Music Mini Player
          Obx(() {
            final SurahMeta? active = controller.currentSurah.value;
            if (active == null) return const SizedBox.shrink();

            final double maxMs =
            controller.duration.value.inMilliseconds.toDouble();
            final double curMs = controller.position.value.inMilliseconds
                .toDouble()
                .clamp(0.0, maxMs > 0 ? maxMs : 1.0);

            return Container(
              padding: EdgeInsets.fromLTRB(14.sz, 8.sz, 14.sz, 12.sz),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20.r),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                      ),
                      child: Slider(
                        value: curMs,
                        max: maxMs > 0 ? maxMs : 1.0,
                        onChanged: (double val) => controller.seekTo(
                          Duration(milliseconds: val.toInt()),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.sz),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            _formatDuration(controller.position.value),
                            style: TextStyle(fontSize: 10.sp),
                          ),
                          Text(
                            _formatDuration(controller.duration.value),
                            style: TextStyle(fontSize: 10.sp),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${active.number}. Surah ${active.englishName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                              Text(
                                controller.selectedQari.value.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: controller.cycleSpeed,
                          child: Text(
                            '${controller.playbackSpeed.value}x',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: controller.playPrevious,
                          icon: Icon(Icons.skip_previous_rounded, size: 28.sz),
                        ),
                        controller.isBuffering.value
                            ? SizedBox(
                          width: 32.sz,
                          height: 32.sz,
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                            : IconButton.filled(
                          onPressed: controller.togglePlayPause,
                          icon: Icon(
                            controller.isPlaying.value
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 28.sz,
                          ),
                        ),
                        IconButton(
                          onPressed: controller.playNext,
                          icon: Icon(Icons.skip_next_rounded, size: 28.sz),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
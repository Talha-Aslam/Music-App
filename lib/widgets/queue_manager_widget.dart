import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../widgets/glassmorphic_container.dart';
import '../utils/helpers/album_art_generator.dart';

class QueueManagerWidget extends StatefulWidget {
  final AudioService audioService;

  const QueueManagerWidget({
    Key? key,
    required this.audioService,
  }) : super(key: key);

  @override
  State<QueueManagerWidget> createState() => _QueueManagerWidgetState();
}

class _QueueManagerWidgetState extends State<QueueManagerWidget> {
  @override
  Widget build(BuildContext context) {
    final playlist = widget.audioService.playlist;

    return GlassmorphicContainer(
      width: 380,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Queue',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Playlist Items with Reordering
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4, // Fixed height instead of constraints
            child: ReorderableListView.builder(
              shrinkWrap: false, // Don't use shrinkWrap with a fixed height container
              itemCount: playlist.length,
              itemBuilder: (context, index) {
                final song = playlist[index];
                final isPlaying = index == widget.audioService.currentIndex;

                return Container(
                  key: ValueKey(song.path),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isPlaying
                        ? Colors.white.withOpacity(0.15)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: isPlaying
                        ? Border.all(color: Colors.blueAccent, width: 1)
                        : null,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: song.albumArt != null
                          ? Image.memory(
                              song.albumArt!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : SizedBox(
                              width: 50,
                              height: 50,
                              child: AlbumArtGenerator.getPlaceholderWidget(
                                song.title ?? song.name,
                                size: 50,
                              ),
                            ),
                    ),
                    title: Text(
                      song.title ?? song.name,
                      style: TextStyle(
                        fontWeight:
                            isPlaying ? FontWeight.bold : FontWeight.normal,
                        color: isPlaying ? Colors.blueAccent : Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      song.artist ?? 'Unknown Artist',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPlaying)
                          Icon(Icons.play_arrow_rounded,
                              color: Colors.blueAccent, size: 18),
                        IconButton(
                          icon: const Icon(Icons.drag_handle),
                          iconSize: 18,
                          onPressed: null,
                        ),
                      ],
                    ),
                    onTap: () async {
                      await widget.audioService.loadSong(index);
                      widget.audioService.play();
                      setState(() {});
                    },
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final song = widget.audioService.playlist.removeAt(oldIndex);
                  widget.audioService.playlist.insert(newIndex, song);

                  // Adjust currentIndex if needed
                  if (widget.audioService.currentIndex == oldIndex) {
                    widget.audioService.currentIndex = newIndex;
                  } else if (widget.audioService.currentIndex < oldIndex &&
                      widget.audioService.currentIndex >= newIndex) {
                    widget.audioService.currentIndex += 1;
                  } else if (widget.audioService.currentIndex > oldIndex &&
                      widget.audioService.currentIndex <= newIndex) {
                    widget.audioService.currentIndex -= 1;
                  }
                });
              },
            ),
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${playlist.length} songs',
                style: TextStyle(color: Colors.white.withOpacity(0.6)),
              ),
              TextButton.icon(
                icon: const Icon(Icons.shuffle),
                label: const Text('Shuffle All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                ),
                onPressed: playlist.isEmpty
                    ? null
                    : () {
                        widget.audioService.toggleShuffle();
                        widget.audioService.next();
                        setState(() {});
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

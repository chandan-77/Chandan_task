import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:chandan_assignment/models/youtube_model.dart';

class YouTubeCard extends StatefulWidget {
  final YoutubeModel video;
  final YoutubePlayerController controller;

  const YouTubeCard({super.key, required this.video, required this.controller});

  @override
  State<YouTubeCard> createState() => _YouTubeCardState();
}

class _YouTubeCardState extends State<YouTubeCard> {
  // Track loading state for the video
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Listen to YouTube player controller to check readiness
    widget.controller.addListener(_controllerListener);
  }

  // Trigger setState when the video player is ready
  void _controllerListener() {
    if (widget.controller.value.isReady && _isLoading) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Always remove listeners to prevent memory leaks
    widget.controller.removeListener(_controllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Channel name in bold
            Text(
              widget.video.channelName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            // Video title
            Text(widget.video.title, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),

            // Embedded YouTube player inside AspectRatio and builder
            AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayerBuilder(
                player: YoutubePlayer(
                  controller: widget.controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.red,
                  onReady: () {
                    // Stop showing loading indicator when player is ready
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  onEnded: (metaData) {
                    // Reset loading flag (optional)
                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
                builder: (context, player) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Main video player
                      player,
                      // Show loading indicator while initializing
                      if (_isLoading)
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
            // Action icons: like, comment, share
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Icon(Icons.thumb_up_alt_outlined, size: 20),
                Icon(Icons.comment_outlined, size: 20),
                Icon(Icons.share_outlined, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

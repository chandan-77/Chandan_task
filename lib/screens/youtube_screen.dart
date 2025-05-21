import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:chandan_assignment/models/youtube_model.dart';
import 'package:chandan_assignment/widget/YoutubeCardWidget.dart';

class YoutubeScreen extends StatefulWidget {
  const YoutubeScreen({super.key});

  @override
  State<YoutubeScreen> createState() => _YoutubeScreenState();
}

class _YoutubeScreenState extends State<YoutubeScreen>
    with AutomaticKeepAliveClientMixin<YoutubeScreen> {
  // List of sample video data using the YoutubeModel
  final List<YoutubeModel> videos = [
    YoutubeModel(
      videoId: 'YQHsXMglC9A',
      channelName: 'AdeleVEVO',
      title: 'Hello',
    ),
    YoutubeModel(
      videoId: 'JGwWNGJdvx8',
      channelName: 'EdSheeran',
      title: 'Perfect',
    ),
    YoutubeModel(
      videoId: 'lp-EO5I60KA',
      channelName: 'PharrellWilliams',
      title: 'Happy',
    ),
    YoutubeModel(
      videoId: 'RgKAFK5djSk',
      channelName: 'Wiz Khalifa',
      title: 'See You Again ft. Charlie Puth',
    ),
    YoutubeModel(
      videoId: 'ktvTqknDobU',
      channelName: 'ImagineDragons',
      title: 'Radioactive',
    ),
    YoutubeModel(
      videoId: 'OPf0YbXqDm0',
      channelName: 'MarkRonsonVEVO',
      title: 'Uptown Funk ft. Bruno Mars',
    ),
  ];

  late List<YoutubePlayerController> controllers; // Controllers for each video
  final ScrollController _scrollController =
      ScrollController(); // Scroll controller
  int _currentVisibleIndex = 0; // Index to track currently visible video
  bool _isLoading = true; // Flag to show loading screen before player setup

  @override
  void initState() {
    super.initState();

    // Delayed initialization to allow context usage and load controllers
    Future.delayed(Duration.zero, () async {
      // Create a YoutubePlayerController for each video
      controllers =
          videos.map((video) {
            return YoutubePlayerController(
              initialVideoId: video.videoId,
              flags: const YoutubePlayerFlags(
                autoPlay: false,
                mute: false,
                forceHD: true,
                disableDragSeek: false,
                enableCaption: false,
                hideControls: false,
                useHybridComposition:
                    true, // Keep this false if you want other controls
              ),
            );
          }).toList();

      // Preload first video
      controllers[0].load(videos[0].videoId);
      _preloadAdjacentVideos(); // Preload next/previous videos

      // Remove loading screen
      setState(() {
        _isLoading = false;
      });

      // Attach scroll listener
      _scrollController.addListener(_handleScroll);
    });
  }

  // Handles scroll to track visible video and preload adjacent videos
  void _handleScroll() {
    final scrollPosition = _scrollController.position;
    final viewportHeight = MediaQuery.of(context).size.height;
    final scrollOffset = scrollPosition.pixels;

    final newVisibleIndex = (scrollOffset / viewportHeight).round();
    if (newVisibleIndex != _currentVisibleIndex) {
      _currentVisibleIndex = newVisibleIndex;
      _preloadAdjacentVideos();
    }
  }

  // Preloads currently visible, next, and previous video
  void _preloadAdjacentVideos() {
    final indicesToPreload = [
      _currentVisibleIndex,
      _currentVisibleIndex + 1,
      _currentVisibleIndex - 1,
    ];

    for (final index in indicesToPreload) {
      if (index >= 0 && index < controllers.length) {
        if (!controllers[index].value.isReady) {
          controllers[index].load(videos[index].videoId);
        }
      }
    }
  }

  @override
  void dispose() {
    // Clean up all controllers
    for (final controller in controllers) {
      controller.pause();
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true; // Keep state alive on tab switch

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for keepAlive mixin
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/4/42/YouTube_icon_%282013-2017%29.png',
            height: 30,
            width: 30,
          ),
        ),
        title: const Text(
          'YouTube',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Icon(Icons.account_circle, color: Colors.black, size: 32),
          ),
        ],
      ),

      // Show loading screen with logo initially
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/4/42/YouTube_icon_%282013-2017%29.png',
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                  ],
                ),
              )
              // Once loaded, show the main video list
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTabs(), // Static filter tabs
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        // Load only currently visible + adjacent videos
                        if ((index - _currentVisibleIndex).abs() <= 1) {
                          if (!controllers[index].value.isReady) {
                            controllers[index].load(videos[index].videoId);
                          }
                        }
                        return YouTubeCard(
                          video: videos[index],
                          controller: controllers[index],
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }

  // UI for top filter tabs (static for now)
  Widget _buildSectionTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTab('Trending', isSelected: true),
          _buildTab('Group'),
          _buildTab('Following'),
        ],
      ),
    );
  }

  // Builds a single filter tab
  Widget _buildTab(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.red.shade100 : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.red : Colors.grey[800],
        ),
      ),
    );
  }
}

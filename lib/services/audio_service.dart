import 'dart:math' as math;
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rxdart/rxdart.dart';
import '../models/song_model.dart';

class AudioService {
  final AudioPlayer audioPlayer = AudioPlayer();
  List<Song> playlist = [];
  int currentIndex = 0;
  bool isShuffle = false;
  bool isRepeat = false;

  // For audio visualization (simulated for now)
  final math.Random _random = math.Random();
  final List<double> _fftData = List.filled(128, 0.0);
  
  // Stream for songs list
  final BehaviorSubject<List<String>> _songsController = BehaviorSubject<List<String>>.seeded([]);
  Stream<List<String>> get songsStream => _songsController.stream;

  // Stream getters for UI to listen to
  Stream<Duration> get positionStream => audioPlayer.positionStream;
  Stream<Duration?> get durationStream => audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => audioPlayer.playerStateStream;
  Stream<ProcessingState> get processingStateStream =>
      audioPlayer.processingStateStream;

  bool get isPlaying => audioPlayer.playing;
  Duration get position => audioPlayer.position;
  Duration get duration => audioPlayer.duration ?? Duration.zero;

  Future<List<Song>> pickFiles() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.audio, allowMultiple: true);

    if (result != null && result.files.isNotEmpty) {
      playlist =
          result.files.map((file) => Song.fromPlatformFile(file)).toList();
      currentIndex = 0;
      
      // Update songs stream
      _songsController.add(playlist.map((song) => song.path).toList());

      if (playlist.isNotEmpty) {
        await loadSong(0);
      }
    }

    return playlist;
  }

  // Add convenience method for home screen
  Future<void> pickAndLoadSongs() async {
    await pickFiles();
  }

  // Add shuffle playlist method
  void shufflePlaylist() {
    if (playlist.isNotEmpty) {
      playlist.shuffle();
      currentIndex = 0;
      _songsController.add(playlist.map((song) => song.path).toList());
      if (isPlaying) {
        loadSong(0);
        play();
      }
    }
  }

  Future<void> loadSong(int index) async {
    if (playlist.isEmpty || index < 0 || index >= playlist.length) return;

    currentIndex = index;
    await audioPlayer.setFilePath(playlist[currentIndex].path);
    await loadMetadata();
  }

  Future<void> loadMetadata() async {
    try {
      // Extract the song name from the filename
      final songFilename = playlist[currentIndex].name;
      
      // Remove file extension to get cleaner song title
      final songTitle = songFilename.split('.').first
          .replaceAll('_', ' ')
          .replaceAll('-', ' - ');
      
      // Set basic metadata
      playlist[currentIndex].title = songTitle;
      playlist[currentIndex].artist = "Unknown Artist";
      
      // Note: We're not setting album art here anymore
      // Instead, we'll use the AlbumArtGenerator in the UI
    } catch (e) {
      print('Error loading metadata: $e');
    }
  }

  void play() {
    audioPlayer.play();
  }

  void pause() {
    audioPlayer.pause();
  }

  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  Future<void> next() async {
    if (playlist.isEmpty) return;

    if (isRepeat) {
      audioPlayer.seek(Duration.zero);
      audioPlayer.play();
      return;
    }

    int nextIndex;
    if (isShuffle) {
      final indices = List.generate(playlist.length, (i) => i)
        ..remove(currentIndex);
      indices.shuffle();
      nextIndex = indices.isNotEmpty ? indices.first : currentIndex;
    } else {
      nextIndex = currentIndex + 1;
      if (nextIndex >= playlist.length) {
        nextIndex = 0;
      }
    }

    await loadSong(nextIndex);
    play();
  }

  Future<void> previous() async {
    if (playlist.isEmpty) return;

    int prevIndex = currentIndex - 1;
    if (prevIndex < 0) {
      prevIndex = playlist.length - 1;
    }

    await loadSong(prevIndex);
    play();
  }

  void toggleShuffle() {
    isShuffle = !isShuffle;
  }

  void toggleRepeat() {
    isRepeat = !isRepeat;
  }

  // Simulated audio data analysis methods
  // These would ideally connect to actual audio buffer data
  // For now, we simulate audio data for visualization

  /// Get FFT (Fast Fourier Transform) data simulated from audio
  /// Returns a list of frequency magnitudes (128 bands)
  List<double> getAudioVisualizerData() {
    if (!isPlaying) {
      return List.filled(128, 0.0);
    }

    // In a real implementation, this would analyze actual audio buffer data
    // For now, we'll generate synthetic data based on playback position
    _updateFFTData();
    return _fftData;
  }

  /// Get primary frequency range for visualization
  /// Returns values between 0-1 for different frequency ranges
  Map<String, double> getFrequencyRanges() {
    final data = getAudioVisualizerData();

    // Simulate different frequency bands
    return {
      'bass': _calculateAverage(data, 0, 15) / 255.0,
      'mid': _calculateAverage(data, 16, 60) / 255.0,
      'treble': _calculateAverage(data, 61, 127) / 255.0,
    };
  }

  // Helper methods for simulating audio data
  void _updateFFTData() {
    // Use position to simulate changing audio patterns
    final posMs = position.inMilliseconds;
    final bpm = 120 + (posMs ~/ 1000) % 60; // Change BPM over time
    final beatInterval = 60000 / bpm; // ms per beat

    final beatPhase = (posMs % beatInterval) / beatInterval;
    final intensity = math.sin(beatPhase * math.pi) * 0.5 + 0.5;

    // Generate simulated frequency data with peaks and patterns
    for (int i = 0; i < _fftData.length; i++) {
      // Base frequency response curve (higher at bass, lower at treble)
      double freqResponse = 1.0 - (i / _fftData.length * 0.7);

      // Add some randomness
      double noise = _random.nextDouble() * 0.3;

      // Add beat emphasis
      double beat = (i < 20) ? intensity * 0.7 : intensity * 0.3;

      // Add some harmonic patterns
      double harmonic = 0.0;
      if (i % 12 == 0) harmonic = 0.2; // Root frequency
      if (i % 12 == 7) harmonic = 0.15; // Fifth
      if (i % 12 == 4) harmonic = 0.1; // Third

      // Combine factors
      _fftData[i] =
          (freqResponse * 0.4 + noise * 0.1 + beat * 0.4 + harmonic) * 255;

      // Ensure values are in range
      _fftData[i] = math.max(0, math.min(255, _fftData[i]));
    }
  }

  double _calculateAverage(List<double> data, int start, int end) {
    if (start >= end || start < 0 || end >= data.length) {
      return 0.0;
    }

    double sum = 0.0;
    for (int i = start; i <= end; i++) {
      sum += data[i];
    }
    return sum / (end - start + 1);
  }

  void dispose() {
    _songsController.close();
    audioPlayer.dispose();
  }
}

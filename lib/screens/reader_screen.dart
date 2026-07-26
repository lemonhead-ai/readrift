import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:go_router/go_router.dart';
import 'package:readrift/security/auth_service.dart';
import 'package:readrift/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readrift/widgets/custom_toast.dart';
import 'package:readrift/services/ai_service.dart';
import 'package:readrift/services/audio_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ReaderScreen extends StatefulWidget {
  final String bookId;
  final String filePath;
  final String bookTitle;
  final String fileType;

  const ReaderScreen({
    super.key,
    required this.bookId,
    required this.filePath,
    required this.bookTitle,
    required this.fileType,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  EpubController? _epubReaderController;
  final AuthService _authService = AuthService();
  final AIService _aiService = AIService();
  final AudioService _audioService = AudioService();
  
  bool _isControlOverlayVisible = true;
  bool _isCompleted = false;
  int _totalPages = 0;
  int _currentPage = 0;
  double _fontSize = 18.0;
  Color _themeBgColor = AppColors.warmWhite;
  int _totalChapters = 1;
  
  // Advanced State
  DateTime? _startTime;
  int _pagesReadThisSession = 0;
  String _timeToFinish = "Calculating...";
  bool _isAISummarizing = false;
  String? _aiSummary;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initializeReader();
  }

  void _calculateReadingVelocity(int currentPage) {
    if (_startTime == null || currentPage <= 0) return;
    
    final elapsedMinutes = DateTime.now().difference(_startTime!).inMinutes;
    if (elapsedMinutes < 1) {
      setState(() {
        _timeToFinish = "Calculating...";
      });
      return;
    }

    final pagesRead = currentPage - _currentPage;
    if (pagesRead > 0) {
      _pagesReadThisSession += pagesRead;
    }

    final pagesPerMinute = _pagesReadThisSession / elapsedMinutes;
    if (pagesPerMinute > 0) {
      final pagesRemaining = _totalPages - currentPage;
      final minutesRemaining = pagesRemaining / pagesPerMinute;
      
      setState(() {
        if (minutesRemaining > 60) {
          _timeToFinish = "${(minutesRemaining / 60).toStringAsFixed(1)} hrs left";
        } else {
          _timeToFinish = "${minutesRemaining.toInt()} mins left";
        }
      });
    }
  }

  Future<void> _getAISummary() async {
    setState(() {
      _isAISummarizing = true;
      _aiSummary = null;
    });

    try {
      // In a real scenario, we'd extract text from the current page/chapter.
      // For now, we'll send a placeholder indicating the context.
      final summary = await _aiService.summarizeContent(
        "Reader is currently on chapter/page $_currentPage of '${widget.bookTitle}'."
      );
      
      setState(() {
        _aiSummary = summary;
        _isAISummarizing = false;
      });
    } catch (e) {
      setState(() {
        _isAISummarizing = false;
      });
      ToastService.showError(context, "AI Summary failed.");
    }
  }

  void _showAudioMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _themeBgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Audio Universe", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAudioOption("Rain", Icons.umbrella_rounded),
                _buildAudioOption("Cafe", Icons.coffee_rounded),
                _buildAudioOption("Focus", Icons.graphic_eq_rounded),
                _buildAudioOption("Off", Icons.volume_off_rounded),
              ],
            ),
            const Divider(height: 40),
            ListTile(
              leading: const Icon(Icons.record_voice_over_rounded, color: AppColors.accentOrange),
              title: const Text("Audiobook Mode (TTS)"),
              subtitle: const Text("Listen to the current page"),
              trailing: Switch(
                value: _audioService.isSpeaking,
                onChanged: (val) {
                  if (val) {
                    _audioService.speak("Reading ${widget.bookTitle}. This is a preview of the text to speech functionality.");
                  } else {
                    _audioService.stopSpeaking();
                  }
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioOption(String label, IconData icon) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: AppColors.accentOrange),
          onPressed: () {
            if (label == "Off") {
              _audioService.stopAmbient();
            } else {
              _audioService.playAmbient(label);
            }
            Navigator.pop(context);
          },
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _initializeReader() {
    if (widget.fileType == 'epub') {
      _epubReaderController = EpubController(
        document: EpubDocument.openFile(File(widget.filePath)),
      );
    }
  }

  void _loadSavedProgress() {
    final user = _authService.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('library')
        .doc(widget.bookId)
        .get()
        .then((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final savedPos = data['currentPosition'] as String?;
        if (savedPos != null && savedPos.isNotEmpty) {
          if (widget.fileType == 'epub') {
            _epubReaderController?.gotoEpubCfi(savedPos);
          } else if (widget.fileType == 'pdf') {
            final page = int.tryParse(savedPos);
            if (page != null) {
              setState(() {
                _currentPage = page;
              });
            }
          }
        }
      }
    });
  }

  Future<void> _updateProgress(double percent, String position) async {
    final user = _authService.currentUser;
    if (user == null) return;

    await _authService.updateReadingProgress(user.uid, widget.bookId, percent, position);
    
    // Record reading session (approx 1 minute per progress update for simplicity)
    await _authService.recordReadingSession(user.uid, minutes: 1);

    if (percent >= 0.99 && !_isCompleted) {
      setState(() {
        _isCompleted = true;
      });
      await _cleanupLocalFile();
    }
  }

  Future<void> _cleanupLocalFile() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final file = File(widget.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      await _authService.updateDownloadStatus(user.uid, widget.bookId, false);

      if (mounted) {
        ToastService.showSuccess(
          context,
          "Finished reading! Local file cleared to free space.",
        );
      }
    } catch (e) {
      debugPrint("Cleanup local book file failed: $e");
    }
  }

  List<EpubChapter>? _chapters;

  void _showTableOfContents() {
    if (_chapters == null || _chapters!.isEmpty) {
      ToastService.showInfo(context, "No table of contents available.");
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: _themeBgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Table of Contents",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _chapters!.length,
                itemBuilder: (context, index) {
                  final chapter = _chapters![index];
                  return ListTile(
                    title: Text(
                      chapter.Title?.trim() ?? "Chapter ${index + 1}",
                      style: TextStyle(
                        color: _themeBgColor == Colors.grey[900]
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    onTap: () {
                      if (chapter.Anchor != null) {
                        _epubReaderController?.scrollTo(index: index);
                      }
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeBgColor(Color color, Color textColor) {
    setState(() {
      _themeBgColor = color;
    });
  }

  void _toggleControlOverlay() {
    setState(() {
      _isControlOverlayVisible = !_isControlOverlayVisible;
    });
  }

  @override
  void dispose() {
    _epubReaderController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeBgColor,
      body: Stack(
        children: [
          // Main content reader
          GestureDetector(
            onTap: _toggleControlOverlay,
            child: widget.fileType == 'epub'
                ? ( _epubReaderController == null 
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accentOrange))
                  : MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(_fontSize / 16.0),
                      ),
                      child: Theme(
                        data: ThemeData(
                          brightness: _themeBgColor == Colors.grey[900]
                              ? Brightness.dark
                              : Brightness.light,
                          scaffoldBackgroundColor: _themeBgColor,
                        ),
                        child: EpubView(
                          controller: _epubReaderController!,
                          onDocumentLoaded: (document) {
                            _totalChapters = document.Chapters?.length ?? 1;
                            _chapters = document.Chapters;
                            _loadSavedProgress();
                          },
                          onChapterChanged: (value) {
                            if (value != null) {
                              final cfi = _epubReaderController!.generateEpubCfi() ?? '';
                              final currentChapter = value.chapterNumber;
                              double percent = 0.0;
                              if (_totalChapters > 0) {
                                percent = (currentChapter / _totalChapters).clamp(0.0, 1.0);
                              }
                              _calculateReadingVelocity(currentChapter);
                              _updateProgress(percent, cfi);
                            }
                          },
                        ),
                      ),
                    )
                  )
                : PDFView(
                    filePath: widget.filePath,
                    enableSwipe: true,
                    swipeHorizontal: true,
                    autoSpacing: true,
                    pageSnap: true,
                    onRender: (pages) {
                      setState(() {
                        _totalPages = pages ?? 0;
                      });
                      _loadSavedProgress();
                    },
                    onPageChanged: (page, total) {
                      if (page != null && total != null && total > 0) {
                        setState(() {
                          _currentPage = page;
                        });
                        final percent = page / (total - 1);
                        _calculateReadingVelocity(page);
                        _updateProgress(percent, page.toString());
                      }
                    },
                  ),
          ),

          // Floating Glass controls header (Top Bar)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            top: _isControlOverlayVisible ? 0 : -100,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.15),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    bottom: 12,
                    left: 16,
                    right: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/');
                          }
                        },
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              widget.bookTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _timeToFinish,
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.accentOrange),
                        onPressed: _getAISummary,
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu_rounded, color: Colors.white),
                        onPressed: _showTableOfContents,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Glass controls footer (Bottom Bar)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            bottom: _isControlOverlayVisible ? 0 : -180,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.15),
                  padding: EdgeInsets.only(
                    top: 16,
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress slider (for PDF) or general page display
                      if (widget.fileType == 'pdf' && _totalPages > 0)
                        Row(
                          children: [
                            Text(
                              "Page ${_currentPage + 1} of $_totalPages",
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const Expanded(child: SizedBox()),
                            Text(
                              "${((_currentPage / (_totalPages - 1)) * 100).round()}% completed",
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      if (widget.fileType == 'epub')
                        const Text(
                          "Progress synced dynamically as you scroll",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      const SizedBox(height: 12),

                      // Actions Row: Font sizing, Palette selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Font Size controls (only for EPUB text scaling)
                          if (widget.fileType == 'epub')
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.format_size_rounded, color: Colors.white, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      if (_fontSize > 12) _fontSize -= 1.0;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.format_size_rounded, color: Colors.white, size: 28),
                                  onPressed: () {
                                    setState(() {
                                      if (_fontSize < 32) _fontSize += 1.0;
                                    });
                                  },
                                ),
                              ],
                            )
                          else
                            const SizedBox.shrink(),

                          // Audio Universe Button
                          IconButton(
                            icon: const Icon(Icons.headphones_rounded, color: Colors.white),
                            onPressed: _showAudioMenu,
                          ),

                          // Theme Background selector
                          Row(
                            children: [
                              _buildThemeButton(AppColors.sepia, Colors.black87, "Sepia"),
                              const SizedBox(width: 8),
                              _buildThemeButton(AppColors.snowyWhite, Colors.black87, "Snowy"),
                              const SizedBox(width: 8),
                              _buildThemeButton(AppColors.oledBlack, Colors.white, "OLED"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // AI Summary Overlay
          if (_isAISummarizing || _aiSummary != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _aiSummary = null),
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _themeBgColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: AppColors.accentOrange),
                            SizedBox(width: 12),
                            Text("AI Insight", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_isAISummarizing)
                          const SpinKitThreeBounce(color: AppColors.accentOrange, size: 30)
                        else
                          Text(_aiSummary!, style: const TextStyle(fontSize: 14, height: 1.5)),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() => _aiSummary = null),
                          child: const Text("Dismiss"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThemeButton(Color color, Color textColor, String label) {
    final isSelected = _themeBgColor == color;
    return GestureDetector(
      onTap: () => _changeBgColor(color, textColor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accentOrange : Colors.white24,
            width: 2.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

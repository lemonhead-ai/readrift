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
  bool _isControlOverlayVisible = true;
  bool _isCompleted = false;
  int _totalPages = 0;
  int _currentPage = 0;
  double _fontSize = 18.0;
  Color _themeBgColor = AppColors.warmWhite;
  int _totalChapters = 1;

  @override
  void initState() {
    super.initState();
    _initializeReader();
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

  void _toggleControlOverlay() {
    setState(() {
      _isControlOverlayVisible = !_isControlOverlayVisible;
    });
  }

  void _changeBgColor(Color color, Color textColor) {
    setState(() {
      _themeBgColor = color;
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
                        child: Text(
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
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu_rounded, color: Colors.white),
                        onPressed: () {
                          // Optional Table of Contents feature
                        },
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
                                const Text("Text Size", style: TextStyle(color: Colors.white, fontSize: 13)),
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

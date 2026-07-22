import 'package:flutter/material.dart';
import 'package:readrift/widgets/glass_card.dart';

class BookCarousel extends StatefulWidget {
  final List<BookItem> books;
  final String title;
  final VoidCallback? onViewAll;
  final Function(BookItem)? onBookTapped;

  const BookCarousel({
    super.key,
    required this.books,
    required this.title,
    this.onViewAll,
    this.onBookTapped,
  });

  @override
  State<BookCarousel> createState() => _BookCarouselState();
}

class _BookCarouselState extends State<BookCarousel> {
  final PageController _pageController = PageController(
    viewportFraction: 0.7,
    keepPage: true,
    initialPage: 0,
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              if (widget.onViewAll != null)
                TextButton(
                  onPressed: widget.onViewAll,
                  child: Text(
                    'View Library',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 380,
          child: widget.books.isEmpty
              ? Center(
                  child: Text(
                    "No books on the shelf yet",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                )
              : PageView.builder(
                  controller: _pageController,
                  itemCount: widget.books.length,
                  itemBuilder: (context, index) {
                    final book = widget.books[index];
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions) {
                          value = _pageController.page! - index;
                          value = (1 - (value.abs() * 0.3)).clamp(0.3, 1.4);
                        }
                        return Transform.scale(
                          scale: Curves.easeOut.transform(value),
                          child: GlassCard(
                            padding: EdgeInsets.zero,
                            onTap: widget.onBookTapped != null
                                ? () => widget.onBookTapped!(book)
                                : null,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 0, 0, 0)
                                        .withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: book.imagePath.startsWith('assets/')
                                        ? Image.asset(
                                            book.imagePath,
                                            height: 280,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            book.imagePath,
                                            height: 280,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                Container(
                                              height: 280,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                  Icons.book_rounded,
                                                  size: 60,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          book.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          book.author,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.7),
                                                fontSize: 16,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class BookItem {
  final String bookId;
  final String title;
  final String author;
  final String imagePath;
  final String? filePath;
  final String fileType;
  final bool downloaded;

  const BookItem({
    required this.bookId,
    required this.title,
    required this.author,
    required this.imagePath,
    this.filePath,
    required this.fileType,
    required this.downloaded,
  });
}


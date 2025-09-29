class BookContent {
  final String title;
  final String fullText;
  final List<String> pages;
  final int wordsPerPage;

  BookContent({
    required this.title,
    required this.fullText,
    required this.wordsPerPage,
  }) : pages = _splitIntoPages(fullText, wordsPerPage);

  static List<String> _splitIntoPages(String text, int wordsPerPage) {
    final words = text.split(RegExp(r'\s+'));
    final pages = <String>[];
    
    for (int i = 0; i < words.length; i += wordsPerPage) {
      final endIndex = (i + wordsPerPage > words.length) 
          ? words.length 
          : i + wordsPerPage;
      
      final pageWords = words.sublist(i, endIndex);
      pages.add(pageWords.join(' '));
    }
    
    return pages;
  }

  String getTextUpToPage(int pageNumber) {
    if (pageNumber <= 0 || pageNumber > pages.length) {
      return '';
    }
    
    return pages.sublist(0, pageNumber).join('\n\n');
  }

  int get totalPages => pages.length;
  
  String getPageContent(int pageNumber) {
    if (pageNumber <= 0 || pageNumber > pages.length) {
      return '';
    }
    return pages[pageNumber - 1];
  }

  double getProgressPercentage(int pageNumber) {
    if (totalPages == 0) return 0.0;
    return (pageNumber / totalPages).clamp(0.0, 1.0);
  }
}
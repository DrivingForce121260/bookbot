import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/summary.dart' as models;
import '../services/database_service.dart';
import '../services/summary_service.dart';

class BookProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final SummaryService _summaryService = SummaryService();

  List<Book> _books = [];
  List<models.Summary> _summaries = [];
  bool _isLoading = false;
  String? _error;

  List<Book> get books => _books;
  List<models.Summary> get summaries => _summaries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Statistiken
  int get totalBooks => _books.length;
  int get completedBooks => _books.where((book) => book.progressPercentage >= 1.0).length;
  int get totalPagesRead => _books.fold(0, (sum, book) => sum + book.currentPage);
  int get totalPages => _books.fold(0, (sum, book) => sum + book.totalPages);

  /// Lädt alle Bücher aus der Datenbank
  Future<void> loadBooks() async {
    _setLoading(true);
    try {
      _books = await _databaseService.getAllBooks();
      _clearError();
    } catch (e) {
      _setError('Fehler beim Laden der Bücher: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Fügt ein neues Buch hinzu
  Future<bool> addBook(Book book) async {
    try {
      final id = await _databaseService.insertBook(book);
      final newBook = book.copyWith(id: id);
      _books.insert(0, newBook);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Fehler beim Hinzufügen des Buches: $e');
      return false;
    }
  }

  /// Aktualisiert ein Buch
  Future<bool> updateBook(Book book) async {
    try {
      await _databaseService.updateBook(book);
      final index = _books.indexWhere((b) => b.id == book.id);
      if (index != -1) {
        _books[index] = book;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('Fehler beim Aktualisieren des Buches: $e');
      return false;
    }
  }

  /// Aktualisiert den Lese-Fortschritt eines Buches
  Future<bool> updateBookProgress(int bookId, int currentPage) async {
    try {
      await _databaseService.updateBookProgress(bookId, currentPage);
      final index = _books.indexWhere((b) => b.id == bookId);
      if (index != -1) {
        _books[index] = _books[index].copyWith(
          currentPage: currentPage,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('Fehler beim Aktualisieren des Fortschritts: $e');
      return false;
    }
  }

  /// Löscht ein Buch
  Future<bool> deleteBook(int bookId) async {
    try {
      await _databaseService.deleteBook(bookId);
      _books.removeWhere((book) => book.id == bookId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Fehler beim Löschen des Buches: $e');
      return false;
    }
  }

  /// Ruft ein Buch anhand der ID ab
  Book? getBookById(int id) {
    try {
      return _books.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Lädt Zusammenfassungen für ein Buch
  Future<void> loadSummariesForBook(int bookId) async {
    try {
      _summaries = await _summaryService.getSummariesForBook(bookId);
      notifyListeners();
    } catch (e) {
      _setError('Fehler beim Laden der Zusammenfassungen: $e');
    }
  }

  /// Generiert eine neue Zusammenfassung
  Future<models.Summary?> generateSummary(int bookId, int targetPage) async {
    try {
      final book = getBookById(bookId);
      if (book == null) {
        _setError('Buch nicht gefunden');
        return null;
      }

      final summary = await _summaryService.generateAndSaveSummary(book, targetPage);
      await loadSummariesForBook(bookId);
      return summary;
    } catch (e) {
      _setError('Fehler beim Generieren der Zusammenfassung: $e');
      return null;
    }
  }

  /// Löscht eine Zusammenfassung
  Future<bool> deleteSummary(int summaryId) async {
    try {
      await _summaryService.deleteSummary(summaryId);
      _summaries.removeWhere((summary) => summary.id == summaryId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Fehler beim Löschen der Zusammenfassung: $e');
      return false;
    }
  }

  /// Ruft die neuesten Bücher ab (für die Startseite)
  List<Book> getRecentBooks({int limit = 3}) {
    return _books.take(limit).toList();
  }

  /// Sucht Bücher nach Titel oder Autor
  List<Book> searchBooks(String query) {
    if (query.isEmpty) return _books;
    
    final lowercaseQuery = query.toLowerCase();
    return _books.where((book) {
      return book.title.toLowerCase().contains(lowercaseQuery) ||
             book.author.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Sortiert Bücher nach verschiedenen Kriterien
  List<Book> getSortedBooks(SortType sortType) {
    switch (sortType) {
      case SortType.title:
        return List.from(_books)..sort((a, b) => a.title.compareTo(b.title));
      case SortType.author:
        return List.from(_books)..sort((a, b) => a.author.compareTo(b.author));
      case SortType.progress:
        return List.from(_books)..sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
      case SortType.dateAdded:
        return List.from(_books)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortType.lastUpdated:
        return List.from(_books)..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}

enum SortType {
  title,
  author,
  progress,
  dateAdded,
  lastUpdated,
}
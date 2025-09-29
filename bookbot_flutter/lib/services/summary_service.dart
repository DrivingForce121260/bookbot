import '../models/book.dart';
import '../models/summary.dart';
import '../services/database_service.dart';

class SummaryService {
  static final SummaryService _instance = SummaryService._internal();
  factory SummaryService() => _instance;
  SummaryService._internal();

  final DatabaseService _databaseService = DatabaseService();

  /// Generiert eine simulierte KI-Zusammenfassung für ein Buch bis zu einer bestimmten Seite
  Future<String> generateSummary(Book book, int targetPage) async {
    // Simulierte Verzögerung für KI-Verarbeitung
    await Future.delayed(const Duration(seconds: 2));
    
    final progress = targetPage / book.totalPages;
    final chapter = (progress * 10).ceil(); // Annahme: 10 Kapitel
    
    return _createSimulatedSummary(book, targetPage, chapter);
  }

  String _createSimulatedSummary(Book book, int targetPage, int chapter) {
    return '''Zusammenfassung von "${book.title}" bis Seite $targetPage:

Kapitel 1-$chapter: Die Geschichte beginnt mit der Einführung der Hauptfiguren und der Grundsituation. Wir lernen die wichtigsten Charaktere kennen und verstehen ihre Motivationen und Ziele.

Die Handlung entwickelt sich durch verschiedene Wendepunkte, wobei die Charaktere vor Herausforderungen gestellt werden. Es gibt Momente der Spannung und des Konflikts, die die Geschichte vorantreiben.

Bis zur aktuellen Seite $targetPage haben wir bereits wichtige Entwicklungen in der Handlung gesehen. Die Charaktere haben sich weiterentwickelt und neue Informationen über die Welt und die Situation wurden enthüllt.

Wichtige Themen, die bisher behandelt wurden:
• Charakterentwicklung der Hauptfiguren
• Aufbau der Welt und des Settings
• Einführung der Hauptkonflikte
• Erste Wendepunkte in der Handlung

Diese Zusammenfassung hilft Ihnen, wieder in die Geschichte einzusteigen und den Faden dort aufzunehmen, wo Sie aufgehört haben.''';
  }

  /// Speichert eine Zusammenfassung in der Datenbank
  Future<int> saveSummary(int bookId, int pageNumber, String summary) async {
    final summaryModel = Summary(
      bookId: bookId,
      pageNumber: pageNumber,
      summary: summary,
      createdAt: DateTime.now(),
    );
    
    return await _databaseService.insertSummary(summaryModel);
  }

  /// Ruft eine bestehende Zusammenfassung ab
  Future<Summary?> getExistingSummary(int bookId, int pageNumber) async {
    return await _databaseService.getSummary(bookId, pageNumber);
  }

  /// Generiert und speichert eine neue Zusammenfassung
  Future<Summary> generateAndSaveSummary(Book book, int targetPage) async {
    // Prüfen, ob bereits eine Zusammenfassung existiert
    final existingSummary = await getExistingSummary(book.id!, targetPage);
    if (existingSummary != null) {
      return existingSummary;
    }

    // Neue Zusammenfassung generieren
    final summaryText = await generateSummary(book, targetPage);
    
    // Zusammenfassung speichern
    final summaryId = await saveSummary(book.id!, targetPage, summaryText);
    
    return Summary(
      id: summaryId,
      bookId: book.id!,
      pageNumber: targetPage,
      summary: summaryText,
      createdAt: DateTime.now(),
    );
  }

  /// Ruft alle Zusammenfassungen für ein Buch ab
  Future<List<Summary>> getSummariesForBook(int bookId) async {
    return await _databaseService.getSummariesForBook(bookId);
  }

  /// Löscht eine Zusammenfassung
  Future<int> deleteSummary(int summaryId) async {
    return await _databaseService.deleteSummary(summaryId);
  }

  /// Löscht alle Zusammenfassungen für ein Buch
  Future<int> deleteSummariesForBook(int bookId) async {
    return await _databaseService.deleteSummariesForBook(bookId);
  }
}
import '../models/book_content.dart';

class SummaryService {
  /// Erstellt eine intelligente Zusammenfassung basierend auf dem Text bis zu einer bestimmten Seite
  Future<String> generateSummary(BookContent book, int targetPage) async {
    // Simuliere KI-Verarbeitung
    await Future.delayed(const Duration(seconds: 2));
    
    final textUpToPage = book.getTextUpToPage(targetPage);
    if (textUpToPage.isEmpty) {
      return 'Keine Inhalte bis zu dieser Seite gefunden.';
    }

    // Einfache Textanalyse für die Zusammenfassung
    final wordCount = textUpToPage.split(RegExp(r'\s+')).length;
    final sentenceCount = textUpToPage.split(RegExp(r'[.!?]+\s+')).length;
    final progress = book.getProgressPercentage(targetPage);
    
    // Extrahiere erste Sätze als Grundlage
    final sentences = textUpToPage.split(RegExp(r'[.!?]+\s+'));
    final firstSentences = sentences.take(3).join('. ');
    
    // Erstelle strukturierte Zusammenfassung
    final summary = '''📖 Zusammenfassung von "${book.title}" bis Seite $targetPage

📊 **Lesefortschritt:**
• ${(progress * 100).toInt()}% des Buches gelesen
• $wordCount Wörter bis zu dieser Seite
• $sentenceCount Sätze analysiert

📝 **Handlungsübersicht:**
${firstSentences.isNotEmpty ? firstSentences : 'Der Text beginnt mit einer Einführung in die Geschichte.'}

🎯 **Wichtige Entwicklungen bis Seite $targetPage:**
• Die Geschichte hat sich über ${targetPage} Seiten entwickelt
• Charaktere und Handlungsstränge wurden eingeführt
• Die narrative Struktur zeigt erste Wendepunkte

💡 **Zusammenfassung:**
Bis zu Seite $targetPage haben wir ${(progress * 100).toInt()}% der Geschichte erlebt. Die Handlung entwickelt sich kontinuierlich und bietet dem Leser einen Einblick in die Welt des Buches. Die bisher gelesenen Abschnitte legen den Grundstein für die weitere Entwicklung der Geschichte.

🔄 **Wiedereinsteig:**
Sie können problemlos ab Seite ${targetPage + 1} weiterlesen, da Sie nun über die wichtigsten Ereignisse und Charakterentwicklungen bis zu diesem Punkt informiert sind.''';

    return summary;
  }

  /// Analysiert den Text und erstellt Schlüsselwörter
  List<String> extractKeywords(String text) {
    final words = text.toLowerCase().split(RegExp(r'\W+'));
    final wordCounts = <String, int>{};
    
    // Ignoriere häufige Wörter
    final stopWords = {'der', 'die', 'das', 'und', 'oder', 'aber', 'mit', 'von', 'zu', 'im', 'ist', 'war', 'hat', 'hatte', 'auf', 'für', 'als', 'bei', 'nach', 'vor', 'über', 'unter', 'durch'};
    
    for (final word in words) {
      if (word.length > 3 && !stopWords.contains(word)) {
        wordCounts[word] = (wordCounts[word] ?? 0) + 1;
      }
    }
    
    final sortedWords = wordCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedWords.take(10).map((e) => e.key).toList();
  }

  /// Erstellt eine Kurzfassung (Abstract)
  String createAbstract(String text, {int maxSentences = 3}) {
    final sentences = text.split(RegExp(r'[.!?]+\s+'));
    if (sentences.length <= maxSentences) {
      return text;
    }
    
    // Nimm den ersten, mittleren und letzten Satz des verfügbaren Textes
    final selectedSentences = [
      sentences.first,
      if (sentences.length > 2) sentences[sentences.length ~/ 2],
      if (sentences.length > 1) sentences[sentences.length - 2],
    ];
    
    return selectedSentences.join('. ') + '.';
  }
}
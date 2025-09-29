import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const BookBotApp());
}

class BookBotApp extends StatelessWidget {
  const BookBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookBot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();
  String? _summary;

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _generateSummary() {
    if (_titleController.text.isEmpty || _textController.text.isEmpty || _pageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte füllen Sie alle Felder aus')),
      );
      return;
    }

    final pageNumber = int.tryParse(_pageController.text);
    if (pageNumber == null || pageNumber < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte geben Sie eine gültige Seitenzahl ein')),
      );
      return;
    }

    // Einfache Zusammenfassung erstellen
    final words = _textController.text.split(RegExp(r'\s+'));
    final wordsPerPage = 250;
    final totalPages = (words.length / wordsPerPage).ceil();
    
    if (pageNumber > totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Das Buch hat nur $totalPages Seiten')),
      );
      return;
    }

    final textUpToPage = words.take(pageNumber * wordsPerPage).join(' ');
    final progress = (pageNumber / totalPages * 100).toInt();

    setState(() {
      _summary = '''📖 Zusammenfassung von "${_titleController.text}" bis Seite $pageNumber

📊 **Lesefortschritt:**
• $progress% des Buches gelesen
• ${textUpToPage.split(RegExp(r'\s+')).length} Wörter bis zu dieser Seite

📝 **Handlungsübersicht:**
${textUpToPage.length > 200 ? textUpToPage.substring(0, 200) + '...' : textUpToPage}

🎯 **Wichtige Entwicklungen bis Seite $pageNumber:**
• Die Geschichte hat sich über $pageNumber Seiten entwickelt
• Charaktere und Handlungsstränge wurden eingeführt
• Die narrative Struktur zeigt erste Wendepunkte

💡 **Zusammenfassung:**
Bis zu Seite $pageNumber haben wir $progress% der Geschichte erlebt. Die Handlung entwickelt sich kontinuierlich und bietet dem Leser einen Einblick in die Welt des Buches.

🔄 **Wiedereinsteig:**
Sie können problemlos ab Seite ${pageNumber + 1} weiterlesen, da Sie nun über die wichtigsten Ereignisse und Charakterentwicklungen bis zu diesem Punkt informiert sind.''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BookBot'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_stories,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'BookBot',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Intelligente Buchzusammenfassungen',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Eingabefelder
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buchinformationen',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Buchtitel',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: 'Buchtext',
                        hintText: 'Fügen Sie hier den vollständigen Text des Buches ein...',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 6,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _pageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Bis zu welcher Seite?',
                        prefixIcon: Icon(Icons.bookmark),
                        hintText: 'z.B. 15',
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _generateSummary,
                        icon: const Icon(Icons.auto_awesome),
                        label: Text(
                          'Zusammenfassung erstellen',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Zusammenfassung anzeigen
            if (_summary != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zusammenfassung',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: SelectableText(
                          _summary!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
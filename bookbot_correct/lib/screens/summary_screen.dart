import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/book_content.dart';
import '../services/summary_service.dart';

class SummaryScreen extends StatefulWidget {
  final BookContent bookContent;

  const SummaryScreen({super.key, required this.bookContent});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final TextEditingController _pageController = TextEditingController();
  final SummaryService _summaryService = SummaryService();
  
  String? _summary;
  bool _isGeneratingSummary = false;
  int? _currentSummaryPage;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _generateSummary() async {
    final pageNumber = int.tryParse(_pageController.text);
    
    if (pageNumber == null || pageNumber < 1 || pageNumber > widget.bookContent.totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bitte geben Sie eine Seitenzahl zwischen 1 und ${widget.bookContent.totalPages} ein'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingSummary = true;
      _summary = null;
    });

    try {
      final summary = await _summaryService.generateSummary(widget.bookContent, pageNumber);
      
      setState(() {
        _summary = summary;
        _currentSummaryPage = pageNumber;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zusammenfassung erfolgreich erstellt!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Erstellen der Zusammenfassung: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingSummary = false;
      });
    }
  }

  void _copySummary() {
    if (_summary != null) {
      Clipboard.setData(ClipboardData(text: _summary!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zusammenfassung in Zwischenablage kopiert'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bookContent.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buchinfo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.bookContent.title,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                          'Seiten',
                          widget.bookContent.totalPages.toString(),
                          Icons.description,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Wörter/Seite',
                          widget.bookContent.wordsPerPage.toString(),
                          Icons.text_fields,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Gesamt Wörter',
                          widget.bookContent.fullText.split(RegExp(r'\s+')).length.toString(),
                          Icons.article,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 600.ms),

            const SizedBox(height: 24),

            // Zusammenfassung erstellen
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zusammenfassung erstellen',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      'Bis zu welcher Seite möchten Sie eine Zusammenfassung?',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _pageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Seitenzahl',
                              hintText: '1 - ${widget.bookContent.totalPages}',
                              prefixIcon: const Icon(Icons.bookmark),
                              suffixText: '/ ${widget.bookContent.totalPages}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isGeneratingSummary ? null : _generateSummary,
                            icon: _isGeneratingSummary
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.auto_awesome),
                            label: Text(
                              _isGeneratingSummary ? 'Erstelle...' : 'Erstellen',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    if (_isGeneratingSummary) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Analysiere Text und erstelle intelligente Zusammenfassung...',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

            const SizedBox(height: 24),

            // Zusammenfassung anzeigen
            if (_summary != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Zusammenfassung bis Seite $_currentSummaryPage',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _copySummary,
                                icon: const Icon(Icons.copy),
                                tooltip: 'Kopieren',
                              ),
                              IconButton(
                                onPressed: () {
                                  // Hier könnte Teilen implementiert werden
                                  _copySummary();
                                },
                                icon: const Icon(Icons.share),
                                tooltip: 'Teilen',
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Fortschrittsbalken
                      if (_currentSummaryPage != null) ...[
                        LinearProgressIndicator(
                          value: widget.bookContent.getProgressPercentage(_currentSummaryPage!),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(widget.bookContent.getProgressPercentage(_currentSummaryPage!) * 100).toInt()}% des Buches gelesen',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
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
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 24),
              
              // Aktionen
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _summary = null;
                          _currentSummaryPage = null;
                          _pageController.clear();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        'Neue Zusammenfassung',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home),
                      label: Text(
                        'Zurück zum Start',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
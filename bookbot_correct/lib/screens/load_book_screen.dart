import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/book_content.dart';
import 'summary_screen.dart';

class LoadBookScreen extends StatefulWidget {
  const LoadBookScreen({super.key});

  @override
  State<LoadBookScreen> createState() => _LoadBookScreenState();
}

class _LoadBookScreenState extends State<LoadBookScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _wordsPerPageController = TextEditingController(text: '250');
  
  bool _isLoadingFile = false;
  bool _showTextInput = false;
  String? _loadedFileName;

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _wordsPerPageController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() {
      _isLoadingFile = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'md'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        
        setState(() {
          _textController.text = content;
          _loadedFileName = result.files.single.name;
          _titleController.text = result.files.single.name.replaceAll(RegExp(r'\.(txt|md)$'), '');
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Buch "${result.files.single.name}" erfolgreich geladen!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Laden der Datei: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingFile = false;
      });
    }
  }

  void _proceedToSummary() {
    if (_titleController.text.trim().isEmpty || _textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte geben Sie einen Titel und Text ein'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final wordsPerPage = int.tryParse(_wordsPerPageController.text) ?? 250;
    if (wordsPerPage < 50 || wordsPerPage > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wörter pro Seite muss zwischen 50 und 1000 liegen'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bookContent = BookContent(
      title: _titleController.text.trim(),
      fullText: _textController.text.trim(),
      wordsPerPage: wordsPerPage,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryScreen(bookContent: bookContent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buch laden',
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
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.book_outlined,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Buch für Zusammenfassung vorbereiten',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Laden Sie eine Textdatei hoch oder geben Sie den Text manuell ein',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 600.ms),

            const SizedBox(height: 24),

            // Datei laden
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Option 1: Textdatei hochladen',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_loadedFileName != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Datei geladen: $_loadedFileName',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoadingFile ? null : _pickFile,
                        icon: _isLoadingFile 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.upload_file),
                        label: Text(
                          _isLoadingFile ? 'Lade Datei...' : 'Textdatei auswählen (.txt, .md)',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

            const SizedBox(height: 16),

            // Oder Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'ODER',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),

            const SizedBox(height: 16),

            // Manueller Text
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
                          'Option 2: Text manuell eingeben',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showTextInput = !_showTextInput;
                            });
                          },
                          child: Text(_showTextInput ? 'Verbergen' : 'Anzeigen'),
                        ),
                      ],
                    ),
                    
                    if (_showTextInput) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          labelText: 'Buchtext',
                          hintText: 'Fügen Sie hier den vollständigen Text des Buches ein...',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 8,
                      ),
                    ],
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

            const SizedBox(height: 24),

            // Konfiguration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buchkonfiguration',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
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
                      controller: _wordsPerPageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Wörter pro Seite',
                        prefixIcon: Icon(Icons.format_list_numbered),
                        hintText: 'Standard: 250 Wörter',
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Dies bestimmt, wie der Text in "Seiten" aufgeteilt wird',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 600.ms),

            const SizedBox(height: 32),

            // Weiter Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _proceedToSummary,
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  'Weiter zur Zusammenfassung',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate().slideY(begin: 0.3, duration: 600.ms, delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
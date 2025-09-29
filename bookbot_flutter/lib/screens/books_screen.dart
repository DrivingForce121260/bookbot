import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/book_provider.dart';
import '../models/book.dart';
import '../widgets/book_card.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortType _sortType = SortType.lastUpdated;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().loadBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          if (bookProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final books = _searchQuery.isEmpty
              ? bookProvider.getSortedBooks(_sortType)
              : bookProvider.searchBooks(_searchQuery);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Theme.of(context).primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Meine Bücher',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Suchfeld
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Bücher suchen...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Sortier-Optionen
                      Row(
                        children: [
                          Text(
                            'Sortieren nach:',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<SortType>(
                              value: _sortType,
                              isExpanded: true,
                              items: SortType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(_getSortTypeLabel(type)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _sortType = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Statistiken
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Gesamt',
                              bookProvider.totalBooks.toString(),
                              Icons.library_books,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Fertig',
                              bookProvider.completedBooks.toString(),
                              Icons.check_circle,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'In Bearbeitung',
                              (bookProvider.totalBooks - bookProvider.completedBooks).toString(),
                              Icons.bookmark,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bücher-Liste
              if (books.isEmpty)
                SliverToBoxAdapter(
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            _searchQuery.isEmpty 
                                ? Icons.library_books_outlined 
                                : Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty 
                                ? 'Noch keine Bücher hinzugefügt'
                                : 'Keine Bücher gefunden',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Fügen Sie Ihr erstes Buch hinzu, um loszulegen!'
                                : 'Versuchen Sie einen anderen Suchbegriff.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => context.go('/add-book'),
                              icon: const Icon(Icons.add),
                              label: const Text('Erstes Buch hinzufügen'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final book = books[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          index == 0 ? 0 : 8,
                          16,
                          index == books.length - 1 ? 16 : 8,
                        ),
                        child: BookCard(
                          book: book,
                          onTap: () => context.go('/book/${book.id}'),
                          onSummaryTap: () => context.go('/summary/${book.id}'),
                        ),
                      ).animate().fadeIn(
                        duration: 300.ms,
                        delay: (index * 100).ms,
                      ).slideY(begin: 0.3);
                    },
                    childCount: books.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getSortTypeLabel(SortType type) {
    switch (type) {
      case SortType.title:
        return 'Titel';
      case SortType.author:
        return 'Autor';
      case SortType.progress:
        return 'Fortschritt';
      case SortType.dateAdded:
        return 'Hinzugefügt';
      case SortType.lastUpdated:
        return 'Aktualisiert';
    }
  }
}
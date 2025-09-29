import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';
import '../models/summary.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bookbot.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Bücher-Tabelle
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        totalPages INTEGER NOT NULL,
        currentPage INTEGER DEFAULT 0,
        isbn TEXT,
        coverImage TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Zusammenfassungen-Tabelle
    await db.execute('''
      CREATE TABLE summaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookId INTEGER NOT NULL,
        pageNumber INTEGER NOT NULL,
        summary TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (bookId) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');
  }

  // Buch-Operationen
  Future<int> insertBook(Book book) async {
    final db = await database;
    return await db.insert('books', book.toMap());
  }

  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) => Book.fromMap(maps[i]));
  }

  Future<Book?> getBook(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Book.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateBook(Book book) async {
    final db = await database;
    return await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> updateBookProgress(int id, int currentPage) async {
    final db = await database;
    return await db.update(
      'books',
      {
        'currentPage': currentPage,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBook(int id) async {
    final db = await database;
    return await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Zusammenfassungs-Operationen
  Future<int> insertSummary(Summary summary) async {
    final db = await database;
    return await db.insert('summaries', summary.toMap());
  }

  Future<List<Summary>> getSummariesForBook(int bookId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'summaries',
      where: 'bookId = ?',
      whereArgs: [bookId],
      orderBy: 'pageNumber ASC',
    );
    return List.generate(maps.length, (i) => Summary.fromMap(maps[i]));
  }

  Future<Summary?> getSummary(int bookId, int pageNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'summaries',
      where: 'bookId = ? AND pageNumber = ?',
      whereArgs: [bookId, pageNumber],
      orderBy: 'createdAt DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Summary.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteSummary(int id) async {
    final db = await database;
    return await db.delete(
      'summaries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSummariesForBook(int bookId) async {
    final db = await database;
    return await db.delete(
      'summaries',
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
  }

  // Statistiken
  Future<int> getTotalBooksCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM books');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getCompletedBooksCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM books WHERE currentPage >= totalPages',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalPagesRead() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(currentPage) as total FROM books',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
class Book {
  final int? id;
  final String title;
  final String author;
  final int totalPages;
  final int currentPage;
  final String? isbn;
  final String? coverImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.totalPages,
    this.currentPage = 0,
    this.isbn,
    this.coverImage,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'isbn': isbn,
      'coverImage': coverImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      totalPages: map['totalPages'],
      currentPage: map['currentPage'],
      isbn: map['isbn'],
      coverImage: map['coverImage'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Book copyWith({
    int? id,
    String? title,
    String? author,
    int? totalPages,
    int? currentPage,
    String? isbn,
    String? coverImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      isbn: isbn ?? this.isbn,
      coverImage: coverImage ?? this.coverImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get progressPercentage {
    if (totalPages == 0) return 0.0;
    return currentPage / totalPages;
  }

  String get progressStatus {
    if (currentPage == 0) return 'Nicht begonnen';
    if (progressPercentage < 0.1) return 'Gerade begonnen';
    if (progressPercentage < 0.5) return 'In Bearbeitung';
    if (progressPercentage < 0.9) return 'Fast fertig';
    if (progressPercentage < 1.0) return 'Fast abgeschlossen';
    return 'Abgeschlossen';
  }

  @override
  String toString() {
    return 'Book{id: $id, title: $title, author: $author, totalPages: $totalPages, currentPage: $currentPage}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Book &&
        other.id == id &&
        other.title == title &&
        other.author == author &&
        other.totalPages == totalPages &&
        other.currentPage == currentPage;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        author.hashCode ^
        totalPages.hashCode ^
        currentPage.hashCode;
  }
}
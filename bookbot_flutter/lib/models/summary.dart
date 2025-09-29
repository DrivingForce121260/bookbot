class Summary {
  final int? id;
  final int bookId;
  final int pageNumber;
  final String summary;
  final DateTime createdAt;

  Summary({
    this.id,
    required this.bookId,
    required this.pageNumber,
    required this.summary,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'pageNumber': pageNumber,
      'summary': summary,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Summary.fromMap(Map<String, dynamic> map) {
    return Summary(
      id: map['id'],
      bookId: map['bookId'],
      pageNumber: map['pageNumber'],
      summary: map['summary'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Summary copyWith({
    int? id,
    int? bookId,
    int? pageNumber,
    String? summary,
    DateTime? createdAt,
  }) {
    return Summary(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      pageNumber: pageNumber ?? this.pageNumber,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Summary{id: $id, bookId: $bookId, pageNumber: $pageNumber, summary: $summary}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Summary &&
        other.id == id &&
        other.bookId == bookId &&
        other.pageNumber == pageNumber &&
        other.summary == summary;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        bookId.hashCode ^
        pageNumber.hashCode ^
        summary.hashCode;
  }
}
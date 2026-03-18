class KeyIdea {
  const KeyIdea({
    required this.id,
    required this.bookId,
    required this.title,
    required this.content,
    this.displayOrder = 0,
  });

  final String id;
  final String bookId;
  final String title;
  final String content;
  final int displayOrder;

  factory KeyIdea.fromJson(Map<String, dynamic> json) {
    return KeyIdea(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }
}

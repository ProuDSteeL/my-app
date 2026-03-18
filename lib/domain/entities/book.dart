class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    this.description,
    this.whyRead,
    this.aboutAuthor,
    required this.readTimeMinutes,
    required this.status,
    this.tags = const [],
    this.createdAt,
  });

  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final String? description;
  final String? whyRead;
  final String? aboutAuthor;
  final int readTimeMinutes;
  final String status;
  final List<String> tags;
  final DateTime? createdAt;

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      coverUrl: json['cover_url'] as String?,
      description: json['description'] as String?,
      whyRead: json['why_read'] as String?,
      aboutAuthor: json['about_author'] as String?,
      readTimeMinutes: json['read_time_minutes'] as int? ?? 0,
      status: json['status'] as String? ?? 'draft',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

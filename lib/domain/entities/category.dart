class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.displayOrder = 0,
  });

  final String id;
  final String name;
  final String slug;
  final String? icon;
  final int displayOrder;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }
}

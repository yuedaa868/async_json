/// 图书模型，字段与统一数据集一一对应。
class Book {
  final int id;
  final String title;
  final String category;
  final int borrowCount;

  Book({
    required this.id,
    required this.title,
    required this.category,
    required this.borrowCount,
  });

  /// 从 JSON 对象构造 Book。
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      borrowCount: (json['borrowCount'] as int?)!,
    );
  }

  @override
  String toString() =>
      'Book(id: $id, title: $title, category: $category, borrowCount: $borrowCount)';
}

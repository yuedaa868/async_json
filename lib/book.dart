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

  /// 从 JSON 对象构造 Book；borrowCount 缺失时默认 0。
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      borrowCount: (json['borrowCount'] as int?) ?? 0,
    );
  }

  /// 反向序列化为 JSON 对象，用于 roundtrip（Book -> JSON -> Book）一致性验证。
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'borrowCount': borrowCount,
      };

  @override
  bool operator ==(Object other) =>
      other is Book &&
      other.id == id &&
      other.title == title &&
      other.category == category &&
      other.borrowCount == borrowCount;

  @override
  int get hashCode => Object.hash(id, title, category, borrowCount);

  @override
  String toString() =>
      'Book(id: $id, title: $title, category: $category, borrowCount: $borrowCount)';
}

/// 数据解析相关的可读异常，[message] 即直接展示给用户的提示文本。
class BookDataException implements Exception {
  final String message;

  BookDataException(this.message);

  @override
  String toString() => message;
}

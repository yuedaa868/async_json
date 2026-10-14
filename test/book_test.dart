import 'dart:convert';

import 'package:async_json/book.dart';
import 'package:test/test.dart';

void main() {
  group('Book 模型', () {
    test('fromJson 解析全部字段', () {
      final json = {
        'id': 1,
        'title': '三体',
        'category': '科幻',
        'borrowCount': 87,
      };
      final book = Book.fromJson(json);
      expect(book.id, 1);
      expect(book.title, '三体');
      expect(book.category, '科幻');
      expect(book.borrowCount, 87);
    });

    test('borrowCount 缺失时默认 0', () {
      final book =
          Book.fromJson({'id': 2, 'title': '未知', 'category': '文学'});
      expect(book.borrowCount, 0);
    });

    test('toJson 反向验证 roundtrip 一致', () {
      final json = {
        'id': 3,
        'title': '人类简史',
        'category': '历史',
        'borrowCount': 91,
      };
      final book = Book.fromJson(json);

      // Book -> JSON 文本 -> Book，应与原始对象完全一致
      expect(book.toJson(), json);
      final back =
          Book.fromJson(jsonDecode(jsonEncode(book.toJson())) as Map<String, dynamic>);
      expect(back, book);
    });
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:async_json/book.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  // 1) 定位数据文件：项目根目录下的 data/books.json
  final file = File(p.join(Directory.current.path, 'data', 'books.json'));

  // 文件缺失时给出友好提示，而不是抛出崩溃堆栈
  if (!await file.exists()) {
    print('数据文件缺失，请检查data/books.json');
    return;
  }

  // 2) 异步读取：readAsString() 返回 Future<String>，await 取出内容
  final content = await file.readAsString();

  // 3) 解析：JSON 字符串 -> List<dynamic> -> List<Book>
  final raw = jsonDecode(content) as List<dynamic>;
  final books =
      raw.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();

  // 4) 总数
  print('图书总数: ${books.length}');

  // 5) 各类目数量（Map 统计）
  final byCategory = <String, int>{};
  for (final book in books) {
    byCategory[book.category] = (byCategory[book.category] ?? 0) + 1;
  }
  print('各类目数量:');
  byCategory.forEach((category, count) => print('  $category: $count'));

  // 6) 借阅量 Top3
  final sorted = [...books]
    ..sort((a, b) => b.borrowCount.compareTo(a.borrowCount));
  print('借阅量 Top3:');
  for (final book in sorted.take(3)) {
    print('  ${book.title} - ${book.borrowCount} 次');
  }
}

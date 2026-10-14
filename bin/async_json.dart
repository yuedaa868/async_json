import 'dart:convert';
import 'dart:io';

import 'package:async_json/book.dart';
import 'package:path/path.dart' as p;

/// 数据文件路径（项目根目录下的 data/books.json）。
final String _dataPath = p.join(Directory.current.path, 'data', 'books.json');

/// ---------------------------------------------------------------
/// 改写前的「嵌套回调版」（作业页附，仅作对照，不在 main 中调用）。
/// 用 .then() / .catchError() 层层嵌套：读取 -> 解析 -> 统计，
/// 每深一层就多缩进一级，异常处理分散，可读性差。
/// ---------------------------------------------------------------
void readAndStatsCallbackStyle() {
  File(_dataPath).exists().then((exists) {
    if (!exists) {
      print('数据文件缺失，请检查data/books.json');
      return;
    }
    File(_dataPath).readAsString().then((content) {
      final raw = jsonDecode(content) as List<dynamic>;
      final books =
          raw.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
      _printStats(books); // 再嵌一层回调
    }).catchError((Object e) {
      print('读取失败：$e');
    });
  });
}

/// ---------------------------------------------------------------
/// 改写后的「顺序 await 版」：逻辑自上而下，一行一步，无需层层嵌套。
/// ---------------------------------------------------------------
Future<void> main() async {
  final file = File(_dataPath);

  // 异常一：文件缺失 —— 可读提示，不再抛出崩溃堆栈
  if (!await file.exists()) {
    print('数据文件缺失，请检查data/books.json');
    return;
  }

  final String content;
  try {
    content = await file.readAsString(); // await：等读取完成后再继续
  } on FileSystemException catch (e) {
    print('读取数据文件失败：${e.message}');
    return;
  }

  final List<Book> books;
  try {
    // 异常二（字段缺失）、异常三（类型错误）在解析时统一转成可读提示
    books = _parseBooks(content);
  } on BookDataException catch (e) {
    print(e.message);
    return;
  }

  if (books.isEmpty) {
    print('数据文件为空，没有可统计的图书。');
    return;
  }

  _printStats(books);
  _verifyRoundtrip(books);
}

/// 把 JSON 文本解析成 `List<Book>`，并把底层异常转成可读的 [BookDataException]。
List<Book> _parseBooks(String content) {
  final dynamic decoded;
  try {
    decoded = jsonDecode(content);
  } on FormatException catch (e) {
    throw BookDataException('JSON 解析失败：文件内容不是合法 JSON（${e.message}）');
  }

  if (decoded is! List) {
    throw BookDataException('数据格式错误：顶层应为数组 []');
  }

  final books = <Book>[];
  for (final dynamic item in decoded) {
    if (item is! Map<String, dynamic>) {
      throw BookDataException('数据格式错误：数组元素应为对象 {}');
    }
    // 异常二：字段缺失 —— 指出缺了哪些字段
    final missing =
        ['id', 'title', 'category'].where((key) => !item.containsKey(key)).toList();
    if (missing.isNotEmpty) {
      throw BookDataException('字段缺失：缺少 ${missing.join('、')} 字段（数据项：$item）');
    }
    // 异常三：类型错误 —— 字段类型与模型不符
    try {
      books.add(Book.fromJson(item));
    } on TypeError catch (e) {
      throw BookDataException('字段类型错误：$e（请检查 id/title/category/borrowCount 的类型）');
    }
  }
  return books;
}

/// 输出：总数、各类目数量（Map 统计）、借阅量 Top3。
void _printStats(List<Book> books) {
  print('图书总数: ${books.length}');

  final byCategory = <String, int>{};
  for (final book in books) {
    byCategory[book.category] = (byCategory[book.category] ?? 0) + 1;
  }
  print('各类目数量:');
  byCategory.forEach((category, count) => print('  $category: $count'));

  final sorted = [...books]
    ..sort((a, b) => b.borrowCount.compareTo(a.borrowCount));
  print('借阅量 Top3:');
  for (final book in sorted.take(3)) {
    print('  ${book.title} - ${book.borrowCount} 次');
  }
}

/// toJson 反向验证：Book -> JSON -> Book，前后应完全一致。
void _verifyRoundtrip(List<Book> books) {
  final text = jsonEncode(books.map((b) => b.toJson()).toList());
  final back = (jsonDecode(text) as List<dynamic>)
      .map((e) => Book.fromJson(e as Map<String, dynamic>))
      .toList();

  final same = books.length == back.length &&
      Iterable.generate(books.length).every((i) => books[i] == back[i]);
  print('toJson 反向验证（roundtrip）: ${same ? '一致 OK' : '不一致 FAIL'}');
}

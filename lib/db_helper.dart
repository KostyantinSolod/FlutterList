import 'package:hive_flutter/hive_flutter.dart';

class DBHelper {
  Future<void> initDB() async {
    await Hive.initFlutter();

    if (!Hive.isBoxOpen('users')) await Hive.openBox('users');
    if (!Hive.isBoxOpen('products')) await Hive.openBox('products');

    print('✅ Hive ініціалізовано');
  }

  Future<void> clearAll() async {
    if (!Hive.isBoxOpen('users')) await Hive.openBox('users');
    if (!Hive.isBoxOpen('products')) await Hive.openBox('products');
    print('🧹 Очищаю усі таблиці...');
    await Hive.box('users').clear();
    await Hive.box('products').clear();
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    if (!Hive.isBoxOpen('users')) await Hive.openBox('users');
    final box = Hive.box('users');
    await box.put(user['id'], user);
    print('👤 Збережено користувача: ${user['name']}');
  }

  Future<void> insertProduct(Map<String, dynamic> product) async {
    if (!Hive.isBoxOpen('products')) await Hive.openBox('products');
    final box = Hive.box('products');
    await box.put(product['id'], product);
    print('🛒 Збережено продукт: ${product['title']}');
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    if (!Hive.isBoxOpen('users')) await Hive.openBox('users');
    final box = Hive.box('users');
    print('📥 Витягую ${box.length} користувачів із Hive');
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    if (!Hive.isBoxOpen('products')) await Hive.openBox('products');
    final box = Hive.box('products');
    print('📥 Витягую ${box.length} продуктів із Hive');
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../models/user.dart';
import '../models/product.dart';
import '../db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dbHelper = DBHelper();
  List<User> users = [];
  List<Product> products = [];
  List<dynamic> combinedList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      print(' Отримую дані з API...');
      await fetchAndSaveData(); // завжди пробуємо оновити
    } catch (e) {
      print(' Немає інтернету або помилка API: $e');
    }

    print('Завантажую з локальної бази Hive...');
    await loadFromDatabase();

    print('Усього елементів у списку: ${combinedList.length}');
    setState(() => isLoading = false);
  }

  Future<void> fetchAndSaveData() async {
    print("=====  START FETCHING DATA  =====");

    final userResponse =
    await http.get(Uri.parse('https://dummyjson.com/users'));

    final productResponse =
    await http.get(Uri.parse('https://dummyjson.com/products'));

    print("Users API Status: ${userResponse.statusCode}");
    print("Products API Status: ${productResponse.statusCode}");

    if (userResponse.statusCode != 200) {
      throw Exception("Users API error");
    }
    if (productResponse.statusCode != 200) {
      throw Exception("Products API error");
    }

    // === ДЕКОДУЄМО ЯК MAP! ===
    final Map<String, dynamic> userMap = jsonDecode(userResponse.body);
    final Map<String, dynamic> productMap = jsonDecode(productResponse.body);

    // === ВИТЯГУЄМО СПИСКИ ===
    final List<dynamic> userJson = userMap["users"];
    final List<dynamic> productJson = productMap["products"];

    print("Users extracted: ${userJson.length}");
    print("Products extracted: ${productJson.length}");

    // === КОНВЕРТУЄМО У МОДЕЛІ ===
    users = userJson.map((e) => User.fromJson(e)).toList();
    products = productJson.map((e) => Product.fromJson(e)).toList();

    print("Converted users: ${users.length}");
    print("Converted products: ${products.length}");

    print("Saving to Hive...");

    // ЗБЕРЕЖЕННЯ
    for (final u in users) {
      await dbHelper.insertUser({
        'id': u.id,
        'name': u.name,
        'email': u.email,
      });
    }

    for (final p in products) {
      await dbHelper.insertProduct({
        'id': p.id,
        'title': p.title,
        'price': p.price,
        'category': p.category,
      });
    }

    // Змішаний список
    combinedList = [...users, ...products];
    combinedList.shuffle(Random());
  }






  Future<void> loadFromDatabase() async {
    final userRows = await dbHelper.getUsers();
    final productRows = await dbHelper.getProducts();

    users = userRows.map((row) => User(id: row['id'], name: row['name'], email: row['email'])).toList();
    products = productRows.map((row) => Product(
      id: row['id'],
      title: row['title'],
      category: row['category'] ?? 'Без категорії',
      price: row['price'],
    )).toList();

    combinedList = [...users, ...products];
    combinedList.shuffle(Random());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Змішаний список'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Очистити кеш',
            onPressed: () async {
              //await dbHelper.clearAll();
              setState(() {
                users.clear();
                products.clear();
                combinedList.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Кеш очищено')),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : combinedList.isEmpty
          ? const Center(child: Text('Дані відсутні '))
          : ListView.builder(
        itemCount: combinedList.length,
        itemBuilder: (context, index) {
          final item = combinedList[index];
          if (item is User) {
            return ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: Text(item.name),
              subtitle: Text(item.email),
            );
          } else if (item is Product) {
            return ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.green),
              title: Text(item.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item.price} ₴'),
                  Text('Категорія  ${item.category}'),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

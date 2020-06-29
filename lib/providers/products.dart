import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ]; // Should never be accesed from the outside

  // var _showFavoritesOnly = false;

  List<Product> get items {
    return [..._items]; // Returns a copy of items
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Future<List<Product>> fetchAndSetData() async {
    const url = 'https://flutter-shop-app-65772.firebaseio.com/products.json';

    try {
      final response = await http.get(url);
      final List<Product> loadedData = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      extractedData.forEach((prodId, prodValue) {
        loadedData.add(Product(
          id: prodId,
          title: prodValue['title'],
          description: prodValue['description'],
          imageUrl: prodValue['imageUrl'],
          price: prodValue['price'],
          isFavorite: prodValue['isFavorite'],
        ));
      });

      _items = loadedData;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // Which kind of data that Future will resolve to once it's done
  // we actually don't care, that's why we're resolving to void.
  Future<void> addProduct(Product product) async {
    const url = 'https://flutter-shop-app-65772.firebaseio.com/products.json';
    // http will return a future
    try {
      final response =
          await http // await tells dart that we want to wait for this operation to finish, before we
              // move to our next line in code
              .post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite,
        }),
      );
      print(json.decode(response.body));
      final newProduct = Product(
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        id: json.decode(response.body)['name'],
      );
      print(newProduct.id);
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }

    // return Future.value();
    // This returns a Future which resolves to nothing
    // This wouldn't work

    // return Future.value();
    // This wouldn't work either, because you wouldn't wait for the .then() to execute
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-shop-app-65772.firebaseio.com/products/$id.json';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  void deleteProduct(String id) {
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
}

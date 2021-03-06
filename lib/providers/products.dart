import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> _items = []; // Should never be accesed from the outside

  // var _showFavoritesOnly = false;

  List<Product> get items {
    return [..._items]; // Returns a copy of items
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    try {
      final filterString =
          filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
      var url =
          'https://flutter-shop-app-65772.firebaseio.com/products.json?auth=$authToken&$filterString';
      final List<Product> loadedData = [];

      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }

      url =
          'https://flutter-shop-app-65772.firebaseio.com/userFavorites/$userId.json?auth=$authToken';

      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      extractedData.forEach((prodId, prodValue) {
        loadedData.add(
          Product(
            id: prodId,
            title: prodValue['title'],
            description: prodValue['description'],
            imageUrl: prodValue['imageUrl'],
            price: prodValue['price'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false,
            // favoriteData could not exist
            // because of an user having not favorited an item before
            // that's why we use the ?? operator, in case we have null
          ),
        );
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
    final url =
        'https://flutter-shop-app-65772.firebaseio.com/products.json?auth=$authToken';
    // http will return a future
    try {
      final response =
          await http // await tells dart that we want to wait for this operation to finish, before we
              // move to our next line in code
              .post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': userId,
          },
        ),
      );

      print(json.decode(response.body));

      final newProduct = Product(
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        id: json.decode(response.body)['name'],
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
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
          'https://flutter-shop-app-65772.firebaseio.com/products/$id.json?auth=$authToken';

      await http.patch(
        url,
        body: json.encode(
          {
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          },
        ),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  void deleteProduct(String id) async {
    // Using the optimistic pattern, where we roll back if our product deletion fails
    final url =
        'https://flutter-shop-app-65772.firebaseio.com/products/$id.json?auth=$authToken';

    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    // POST and GET throws error, DELETE does not do that, we end up in the 'then' block
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
      // throw acts like return, cancels function execution
    }

    existingProduct = null;
  }
}

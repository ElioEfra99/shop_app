import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final String authToken;
  List<OrderItem> _orders = [];

  Orders(this.authToken, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    try {
      final url =
          'https://flutter-shop-app-65772.firebaseio.com/orders.json?auth=$authToken';
      final response = await http.post(
        url,
        body: json.encode(
          {
            'amount': total,
            'dateTime': DateTime.now().toIso8601String(),
            'products': cartProducts
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList()
          },
        ),
      );

      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          dateTime: DateTime.now(),
          products: cartProducts,
        ),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://flutter-shop-app-65772.firebaseio.com/orders.json?auth=$authToken';

    try {
      final response = await http.get(url);
      final List<OrderItem> loadedOrders = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }

      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    title: item['title'],
                    quantity: item['quantity'],
                  ))
              .toList(),
          dateTime: DateTime.parse(orderData['dateTime']),
        ));
      });

      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  Future<void> _refreshProducts(BuildContext context) async {
    // We give a context because we don't have one at this point
    await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
    // We simply await for this to finish, and the overall method will only be done once this is done.
  }

  @override
  Widget build(BuildContext context) {
    print('Building orders');
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: RefreshIndicator(
        color: Theme.of(context).primaryColor,
        onRefresh: () => _refreshProducts(context),
        child: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  strokeWidth: 5,
                ),
              );
            } else if (dataSnapshot.error != null) {
              return Center(
                child: Text('An error occurred!!'),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, _) => ListView.builder(
                  itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                  itemCount: orderData.orders.length,
                ),
              );
            }
          },
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}

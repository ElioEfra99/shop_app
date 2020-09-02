import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/app_drawer.dart';

import '../screens/edit_product_screen.dart';
import '../providers/products.dart';
import '../widgets/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    // We give a context because we don't have one at this point
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
    print('refreshing...');
    // We simply await for this to finish, and the overall method will only be done once this is done.
  }

  @override
  Widget build(BuildContext context) {
    print('rebuilding...');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                strokeWidth: 5,
              ),
            );
          } else {
            if (dataSnapshot.error != null) {
              // Error handling
              return Center(
                child: Text('An error occured!'),
              );
            } else {
              return RefreshIndicator(
                color: Theme.of(context).primaryColor,
                onRefresh: () => _refreshProducts(context),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Consumer<Products>(
                    builder: (ctx, productsData, _) {
                      // When refreshed, only this part reloads, the rest of the app doesn't because
                      // of the listen: false
                      return ListView.builder(
                        itemCount: productsData.items.length,
                        itemBuilder: (_, i) => Column(
                          children: [
                            UserProductItem(
                              productsData.items[i].title,
                              productsData.items[i].imageUrl,
                              productsData.items[i].id,
                            ),
                            Divider(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}

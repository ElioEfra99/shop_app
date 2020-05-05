import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './product_item.dart';
import '../providers/products.dart';

class ProductsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(
        context); // Allows us to set up a connection to one of the provided classes
    final products = productsData.items;
    // This is not a list of items, it is an object based in "Products" class, we would have an items getter
    // With this piece of info <Products> we're telling provider package that we want to establish a direct communication
    // channel to the provided instance of the "Products" class
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      // itemBuilder: (ctx, i) => ChangeNotifierProvider(
      //   create: (_) => products[i],  // Underscore to signal that you're not interested in context
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(  // Perfect approach if you use a provider on something that is part of a list or grid
                                                              // Because widgets are recycled and only data changes
        // Here the builder or create approach would allow errors to occur
        // ChangeNotifierProvider automatically cleans up data not used when you change screens
        value: products[i],  // Get the product retrieved up there
        // Create a new provider from one product gathered
        child: ProductItem(
            // products[i].id,
            // products[i].title,
            // products[i].imageUrl,
            // products[i].price,
            ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
    );
  }
}

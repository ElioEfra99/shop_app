import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/auth.dart';
import '../screens/product_detail_screen.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    final product = Provider.of<Product>(context, listen: false);
    // product would re-build the whole widget but consumer only re-builds the part where it is called.
    final cart = Provider.of<Cart>(context,
        listen:
            false); // We just want to notify the cart that we added an item, not update it.
    final auth = Provider.of<Auth>(context, listen: false);

    print('build executed');

    return ClipRRect(
      // Clip rounded rectange (adds rounded corners)
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        header: GridTileBar(
          title: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Text(
              '\$ ${product.price}',
              style: TextStyle(
                backgroundColor: Colors.black26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            // Only run this subpart again
            // Also could have achieved this same behavior by wrapping IconButton bellow inside a widget and put the
            // provider right there since we would only care about the receiving data in only that widget
            builder: (ctx, product, _) => IconButton(
              // _ means I don't need a child
              // builder: (ctx, product, child) => IconButton(
              // First element (left)
              onPressed: () async {
                try {
                  await product.toggleFavorite(auth.token, auth.userId);
                } catch (error) {
                  scaffold.showSnackBar(
                    SnackBar(content: Text('Fav / Unfav failed! 🐣')),
                  );
                }
              },
              // lavel: child // This child references the child in the builder method, it would use Text('Hello')
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              color: Theme.of(context).accentColor,
            ),
            // child: Text('Hello'), // This child wouldn't rebuild once the consumer actually rebuilds
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            // Last element (right)
            icon: Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
            onPressed: () {
              cart.addItems(product.id, product.price, product.title);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Added item to cart!'),
                duration: Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    cart.removeItem(product.id);
                  },
                ),
                backgroundColor: Colors.teal,
              )); // Here, we establish a connection with the nearest Scaffold Widget
            },
          ),
        ),
      ),
    );
  }
}

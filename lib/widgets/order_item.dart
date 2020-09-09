import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem>
    with SingleTickerProviderStateMixin {
  var _expanded = false;
  Animation<double> _iconAnimation;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _iconAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.decelerate));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
      height:
          _expanded ? min(widget.order.products.length * 20.0 + 110, 200) : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text('\$${widget.order.amount}'),
                subtitle: Text(DateFormat('dd/MM/yyyy hh:mm')
                    .format(widget.order.dateTime)),
                trailing: IconButton(
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.menu_arrow,
                    progress: _iconAnimation,
                  ),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });

                    if (_iconAnimation.status == AnimationStatus.dismissed) {
                      _animationController.forward();
                    } else {
                      _animationController.reverse();
                    }
                  },
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: _expanded
                    ? min(widget.order.products.length * 20.0 + 10, 100)
                    : 0,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                child: ListView(
                  children: widget.order.products
                      .map(
                        (product) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              product.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${product.quantity}x \$${product.price}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            )
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

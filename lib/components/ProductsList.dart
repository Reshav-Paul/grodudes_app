import 'package:flutter/material.dart';
import 'package:grodudes/components/ProductListTile.dart';
import 'package:grodudes/models/Product.dart';

class ProductsList extends StatelessWidget {
  final List<Product> items;
  ProductsList(this.items);
  @override
  Widget build(BuildContext context) {
    if (this.items == null || this.items.length == 0) {
      return SizedBox(height: 0);
    }
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, index) => ProductListTile(items[index]),
    );
  }
}

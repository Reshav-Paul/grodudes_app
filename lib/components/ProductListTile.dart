import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grodudes/components/QuantityToggle.dart';
import 'package:grodudes/components/StyledProductPrice.dart';
import 'package:grodudes/helper/ImageFetcher.dart';
import 'package:grodudes/models/Product.dart';
import 'package:grodudes/pages/ProductDetailsPage.dart';

class ProductListTile extends StatelessWidget {
  final Product item;
  ProductListTile(this.item);

  @override
  Widget build(BuildContext context) {
    if (this.item == null || this.item.data['id'] == null) {
      return SizedBox(height: 0);
    }
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ProductDetailsPage(item),
          ),
        );
      },
      child: Container(
        height: 100,
        padding: EdgeInsets.symmetric(vertical: 8),
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 100,
              width: 100,
              child: ImageFetcher.getImage(item.data['images'][0]['src']),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    item.data['name'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  item.data['purchasable'] != null && item.data['purchasable']
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: item.data['in_stock'] == true
                              ? StyledProductPrice(
                                  this.item.data['price'],
                                  this.item.data['regular_price'],
                                )
                              : Text(
                                  'Out of Stock',
                                  style: TextStyle(color: Colors.red[600]),
                                ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Currently Not Purchasable',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        ),
                ],
              ),
            ),
            item.data['purchasable'] != null && item.data['purchasable']
                ? item.data['in_stock'] == true
                    ? QuantityToggle(item)
                    : SizedBox(width: 25)
                : SizedBox(width: 26),
          ],
        ),
      ),
    );
  }
}

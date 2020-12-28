import 'package:flutter/material.dart';
import 'package:grodudes/components/ProductListTile.dart';
import 'package:grodudes/models/Product.dart';
import 'package:grodudes/state/products_state.dart';
import 'package:provider/provider.dart';

class HomeSpecialProductsPage extends StatefulWidget {
  final String title;
  final Set<int> productIds;
  final Future Function() cb;
  HomeSpecialProductsPage(this.title, this.productIds, this.cb);
  @override
  _HomeSpecialProductsPageState createState() =>
      _HomeSpecialProductsPageState();
}

class _HomeSpecialProductsPageState extends State<HomeSpecialProductsPage> {
  bool _isLoading;
  bool requestedOnce;
  @override
  void initState() {
    this._isLoading = false;
    this.requestedOnce = false;
    super.initState();
  }

  Future _getData() async {
    setState(() {
      this._isLoading = true;
    });
    await widget.cb().catchError((err) {
      print('loading error: ' + err.toString());
    });
    setState(() {
      this.requestedOnce = true;
      this._isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.productIds == null || this.widget.productIds.length == 0) &&
        !this.requestedOnce) {
      _getData();
    }
    Map<int, Product> products =
        Provider.of<ProductsManager>(context, listen: false).products;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _isLoading
          ? Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : this.widget.productIds.length == 0 && this.requestedOnce
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Failed to Load Products'),
                      RaisedButton(
                        onPressed: _getData,
                        child: Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: widget.productIds.length,
                  itemBuilder: (context, index) => ProductListTile(
                      products[widget.productIds.elementAt(index)]),
                ),
    );
  }
}

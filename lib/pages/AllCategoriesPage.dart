import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grodudes/components/CategoryCard.dart';
import 'package:grodudes/state/products_state.dart';
import 'package:provider/provider.dart';

class AllCategoriesPage extends StatefulWidget {
  @override
  _AllCategoriesPageState createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ProductsManager>(
      builder: (context, productsManager, child) {
        return FutureBuilder(
          future: productsManager.fetchAllParentCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done)
              return Center(child: CircularProgressIndicator());
            if (snapshot.hasData) {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                padding: EdgeInsets.all(16),
                itemCount: productsManager.categories.length,
                itemBuilder: (context, index) {
                  return CategoryCard(
                    productsManager.categories.values.elementAt(index),
                  );
                },
              );
            }
            if (snapshot.hasError) {
              print(snapshot.error);
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to fetch categories'),
                  RaisedButton(
                    child: Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => setState(() {}),
                  )
                ],
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}

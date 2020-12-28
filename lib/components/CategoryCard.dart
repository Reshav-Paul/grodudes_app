import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grodudes/components/ProductsList.dart';
import 'package:grodudes/helper/ImageFetcher.dart';
import 'package:grodudes/models/Category.dart';
import 'package:grodudes/state/products_state.dart';
import 'package:provider/provider.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  CategoryCard(this.category);

  String _formatName(String name) {
    return name.replaceAll('&amp;', '&');
  }

  @override
  Widget build(BuildContext context) {
    if (this.category == null || this.category.data['id'] == null) {
      return SizedBox(width: 0, height: 0);
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) {
              return CategoryContents(category: category);
            },
          ),
        );
      },
      child: Container(
        // margin: EdgeInsets.only(top: 16, bottom: 6, left: 8, right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Color(0xffd5d5d5), blurRadius: 3, spreadRadius: 1)
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: category.data['image'] != null
                  ? ImageFetcher.getImage(category.data['image']['src'])
                  : Icon(Icons.image, size: 70),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                _formatName(category.data['name']),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryContents extends StatefulWidget {
  const CategoryContents({
    Key key,
    @required this.category,
  }) : super(key: key);

  final Category category;

  @override
  _CategoryContentsState createState() => _CategoryContentsState();
}

class _CategoryContentsState extends State<CategoryContents> {
  String _formatName(String name) {
    return name.replaceAll('&amp;', '&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_formatName(this.widget.category.data['name'])),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: Provider.of<ProductsManager>(context)
            .fetchCategoryDetails(widget.category),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red[600]),
                  Text(
                    'An error occured while loading',
                    style: TextStyle(fontSize: 16),
                  ),
                  RaisedButton(
                    child: Text('Retry', style: TextStyle(color: Colors.white)),
                    onPressed: () => setState(() {}),
                  )
                ],
              ),
            );
          }
          if (snapshot.hasData) {
            if (snapshot.data['products'] != null) {
              return ProductsList(snapshot.data['products']);
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data['categories'].length,
              itemBuilder: (context, index) =>
                  CategoryCard(snapshot.data['categories'][index]),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

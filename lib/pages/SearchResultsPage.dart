import 'package:flutter/material.dart';
import 'package:grodudes/components/ProductListTile.dart';
import 'package:grodudes/helper/Constants.dart';
import 'package:grodudes/models/Product.dart';
import 'package:grodudes/state/products_state.dart';
import 'package:provider/provider.dart';

class SearchResultsPage extends StatefulWidget {
  final String searchQuery;
  SearchResultsPage(this.searchQuery);
  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  TextEditingController _searchController;

  @override
  void initState() {
    this._searchController = TextEditingController(text: widget.searchQuery);
    super.initState();
  }

  void loadSearch() {
    setState(() {
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: GrodudesPrimaryColor.primaryColor[400], width: 2),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: this._searchController,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Search Grodudes...',
                    hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black38),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: InputBorder.none,
                  ),
                  cursorColor: GrodudesPrimaryColor.primaryColor[600],
                  onSubmitted: (value) => loadSearch(),
                ),
              ),
              GestureDetector(
                onTap: loadSearch,
                child: Icon(Icons.search,
                    size: 24, color: GrodudesPrimaryColor.primaryColor[700]),
              ),
              SizedBox(width: 6),
            ],
          ),
        ),
      ),
      body: FutureBuilder(
        future: Provider.of<ProductsManager>(context, listen: false)
            .searchProducts(this._searchController.text),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) {
            return Center(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  'An Error Occured. Please Try Again',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            List<Product> items = snapshot.data;
            return ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (context, index) => ProductListTile(items[index]),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

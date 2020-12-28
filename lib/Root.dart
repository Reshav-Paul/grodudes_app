import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grodudes/components/RootDrawer.dart';
import 'package:grodudes/helper/Constants.dart';
import 'package:grodudes/pages/AllCategoriesPage.dart';
import 'package:grodudes/pages/AllProductsPage.dart';
import 'package:grodudes/pages/CartItems.dart';
import 'package:grodudes/pages/Home.dart';
import 'package:grodudes/pages/SearchResultsPage.dart';
import 'package:grodudes/pages/account/AccountRoot.dart';

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> with SingleTickerProviderStateMixin {
  var currentPage;
  TabController _tabController;
  TextEditingController _searchController;

  @override
  initState() {
    this._tabController =
        TabController(initialIndex: 0, length: 3, vsync: this);
    this._searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    this._tabController.dispose();
    this._searchController.dispose();
    super.dispose();
  }

  openSearchPage(String searchQuery) {
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    this._searchController.clear();
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => SearchResultsPage(searchQuery),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 2,
        iconTheme: IconThemeData(color: Colors.black87, size: 36),
        actionsIconTheme:
            IconThemeData(color: GrodudesPrimaryColor.primaryColor[700]),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 3)],
            borderRadius: BorderRadius.circular(16),
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
                        EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) => openSearchPage(value),
                ),
              ),
              GestureDetector(
                onTap: () => openSearchPage(this._searchController.text),
                child: Icon(
                  Icons.search,
                  size: 24,
                  color: GrodudesPrimaryColor.primaryColor[700],
                ),
              ),
              SizedBox(width: 6),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.shopping_cart),
            constraints: BoxConstraints(maxHeight: 38, maxWidth: 38),
            onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => CartItems()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.person),
            constraints: BoxConstraints(maxHeight: 38, maxWidth: 38),
            onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => AccountRoot()),
            ),
          ),
        ],
      ),
      drawer: RootDrawer(),
      body: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: this._tabController,
              // isScrollable: true,
              indicatorColor: GrodudesPrimaryColor.primaryColor[600],
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: GrodudesPrimaryColor.primaryColor[600],
              labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              unselectedLabelColor: Colors.black87,
              tabs: [
                Tab(child: Text('Home')),
                Tab(child: Text('Products')),
                Tab(child: Text('Categories')),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: this._tabController,
              children: [
                Home(() => this._tabController.animateTo(2)),
                AllProductsPage(),
                AllCategoriesPage(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

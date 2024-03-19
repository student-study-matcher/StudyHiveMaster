import 'package:flutter/material.dart';
import 'index.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<dynamic> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    } else {
      setState(() => _searchResults.clear());
    }
  }

  _performSearch(String query) async {
    // Your search implementation
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 4,
      centerTitle: false,
      automaticallyImplyLeading: false,
      backgroundColor: Color(0xffad32fe),
      title: !_isSearching
          ? GestureDetector(
        onTap: () => Navigator.of(context).pushReplacementNamed('/home'),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            Image.asset('assets/logo.png', width: 24),
            SizedBox(width: 8),
            Text("Study Hive",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.white)),
          ],
        ),
      )
          : TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search...",
          hintStyle: TextStyle(color: Colors.white),
          border: InputBorder.none,
        ),
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        if (!_isSearching)
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
        if (_isSearching)
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
                _searchResults.clear();
              });
            },
          ),
      ],
    );
  }
}
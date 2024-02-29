import 'package:flutter/material.dart';

class FriendsPopup extends StatefulWidget {
  final List<String> friends;
  final void Function(String) onFriendSelected;
  final VoidCallback onClose;

  FriendsPopup({
    required this.friends,
    required this.onFriendSelected,
    required this.onClose,
  });

  @override
  _FriendsPopupState createState() => _FriendsPopupState();
}

class _FriendsPopupState extends State<FriendsPopup> {
  late List<String> filteredFriends;

  @override
  void initState() {
    super.initState();
    filteredFriends = List.from(widget.friends);
  }

  void filterFriends(String query) {
    setState(() {
      filteredFriends = widget.friends
          .where((friend) => friend.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        padding: EdgeInsets.all(16.0),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Friends',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              onChanged: filterFriends,
              decoration: InputDecoration(
                hintText: 'Search Friends...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: filteredFriends.map((friend) {
                    return ListTile(
                      title: Text(friend),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                        },
                      ),
                      onTap: () {
                        widget.onFriendSelected(friend);
                        widget.onClose();
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
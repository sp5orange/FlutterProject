import 'package:flutter/material.dart';
import 'package:grocerylist/pages/login_page.dart';
import 'package:grocerylist/pages/viewlist_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateList extends StatefulWidget {
  final String listName;

  const UpdateList({Key? key, required this.listName}) : super(key: key);

  @override
  _UpdateListsPageState createState() => _UpdateListsPageState();
}

class ListItem {
  String name;
  bool isChecked;

  ListItem({required this.name, this.isChecked = false});
}

class _UpdateListsPageState extends State<UpdateList> {
  List<ListItem> _items = [];

  @override
  void initState() {
    super.initState();
    fetchListDetails();
  }

  final TextEditingController _listNameController = TextEditingController();
  final TextEditingController _listDescriptionController = TextEditingController();

  @override
  void dispose() {
    _listNameController.dispose();
    _listDescriptionController.dispose();
    super.dispose();
  }

  Future<void> fetchListDetails() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('grocery lists')
        .where('ListName', isEqualTo: widget.listName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final itemsList = doc.data()['items'] as List<dynamic>? ?? [];
      final checkedItemsList = doc.data()['checkedItems'] as List<dynamic>? ?? [];

      setState(() {
        _listNameController.text = widget.listName;
        _items = itemsList.map((item) => ListItem(name: item.toString(), isChecked: false)).toList() +
                 checkedItemsList.map((item) => ListItem(name: item.toString(), isChecked: true)).toList();
      });
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      await auth.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error logging out. Please try again.')),
      );
    }
  }

  Future<void> addItem(String listName, String itemName) async {
    final collectionRef = FirebaseFirestore.instance.collection('grocery lists');
    final querySnapshot = await collectionRef.where('ListName', isEqualTo: listName).get();

    if (querySnapshot.docs.isNotEmpty) {
      final docRef = querySnapshot.docs.first.reference;
      await docRef.update({
        'items': FieldValue.arrayUnion([itemName]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item Added successfully!')));
      fetchListDetails();
    }
  }

  Future<String?> _promptForNewItem() async {
    String? item;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter item name'),
          content: TextField(
            onChanged: (value) {
              item = value;
            },
            decoration: const InputDecoration(hintText: "item name"),
            keyboardType: TextInputType.text,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return item;
  }

  void deleteItem(String listName, String itemName) async {
    final collectionRef = FirebaseFirestore.instance.collection('grocery lists');
    final querySnapshot = await collectionRef.where('ListName', isEqualTo: listName).get();

    if (querySnapshot.docs.isNotEmpty) {
      final docRef = querySnapshot.docs.first.reference;
      // Remove item from both lists in a single update
      await docRef.update({
        'items': FieldValue.arrayRemove([itemName]),
        'checkedItems': FieldValue.arrayRemove([itemName]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$itemName removed')),
      );

      // Refresh the list to reflect the changes
      fetchListDetails();
    }
  }

  void updateItemStatus(String listName, ListItem item, bool isChecked) async {
    final collectionRef = FirebaseFirestore.instance.collection('grocery lists');
    final querySnapshot = await collectionRef.where('ListName', isEqualTo: listName).get();
  
    if (querySnapshot.docs.isNotEmpty) {
      final docRef = querySnapshot.docs.first.reference;
      if (isChecked) {
        await docRef.update({
          'items': FieldValue.arrayRemove([item.name]),
          'checkedItems': FieldValue.arrayUnion([item.name]),
        });
      } else {
        await docRef.update({
          'checkedItems': FieldValue.arrayRemove([item.name]),
          'items': FieldValue.arrayUnion([item.name]),
        });
      }
    }

    fetchListDetails();

  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blue,
      centerTitle: true,
      title: const Text(
        'Update Your List',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () => _signOut(context),
          tooltip: 'Sign out',
          padding: const EdgeInsets.only(right: 15),
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
      ],
    ),
    body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: TextField(
              controller: _listNameController,
              decoration: InputDecoration(
                labelText: 'List Title',
                filled: true,
                fillColor: Colors.white.withOpacity(0.7),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            height: 300,
            child: RefreshIndicator(
              onRefresh: () async {
                await fetchListDetails();
              },
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Dismissible(
                    key: Key(item.name), // Unique key for Dismissible widget
                    background: Container(color: Colors.red), // Red background on swipe
                    onDismissed: (direction) {
                      deleteItem(widget.listName, item.name);
                    },
                    child: CheckboxListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          color: item.isChecked ? Colors.grey : Colors.black,
                          decoration: item.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                      value: item.isChecked,
                      onChanged: (bool? newValue) {
                        setState(() {
                          item.isChecked = newValue!;
                        });
                        updateItemStatus(widget.listName, item, newValue!);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () async {
                      final itemName = await _promptForNewItem();
                      if (itemName != null && itemName.isNotEmpty) {
                        addItem(widget.listName, itemName);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue,
                    ),
                    child: const Text('Add Item'),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ViewListsPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue,
                    ),
                    child: const Text('Back'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}}
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

  // Text editing controllers
  final TextEditingController _listNameController = TextEditingController();
  final TextEditingController _listDescriptionController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
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
      final itemsList = doc.data()['items'] as List<dynamic>;

      // Populate _items with the fetched items
      setState(() {
        _listNameController.text = widget.listName; // Set list name
        _items = itemsList.map((item) => ListItem(name: item.toString())).toList();
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

Future<void> addItem(String listName) async {
    final item = await _promptForNewItem();
    if (item == null || item.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('grocery lists')
          .where('ListName', isEqualTo: listName)
          .get()
          .then((querySnapshot) {
        for (var document in querySnapshot.docs) {
          document.reference.update({
            'items': FieldValue.arrayUnion([item])
          });
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item Added successfully!')));
        
      fetchListDetails();
      
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add item: $e')));
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
            icon: const Icon(Icons.exit_to_app), // Sign-out icon
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
            height: 300, // Set a height that makes sense for your app
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return CheckboxListTile(
                  title: Text(item.name),
                  value: item.isChecked,
                  onChanged: (bool? newValue) {
                    setState(() {
                      item.isChecked = newValue!;
                    });
                    
                  },
                );
              },
            ),
          ),
            Container(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {
                        addItem(widget.listName);
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
  }
}

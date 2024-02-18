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

class _UpdateListsPageState extends State<UpdateList> {
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
    final itemsString = itemsList.join(', ');

    // Use setState to update the text fields with fetched data
    setState(() {
      _listNameController.text = widget.listName; // Set list name
      _listDescriptionController.text = itemsString; // Set list description
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
          SnackBar(content: Text('Error logging out. Please try again.')),
        );
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(
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
            padding: EdgeInsets.only(right: 15),
            color: Color.fromARGB(255, 255, 255, 255),
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
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: TextField(
                maxLines: null,
                controller: _listDescriptionController,
                decoration: InputDecoration(
                  labelText: 'List Description',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                  border: const OutlineInputBorder(),
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
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ViewListsPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                      ),
                      child: const Text('Update Your List'),
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
                        primary: Colors.blue,
                        onPrimary: Colors.white,
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

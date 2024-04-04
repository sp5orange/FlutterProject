import 'package:flutter/material.dart';
import 'package:grocerylist/pages/viewlist_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateList extends StatelessWidget {
  CreateList({super.key});

  final TextEditingController _listNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> createGroceryList(String listName, String description) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final items = description.split(',').map((e) => e.trim()).toList(); // Split by comma and trim spaces

    await FirebaseFirestore.instance.collection('grocery lists').add({
      'CreatedBy': uid,
      'ListName': listName,
      'items': items,
      'sharedWith': [],
      'checkedItems': [],
    });
  }

  @override
  Widget build(BuildContext context) {
    // Even though we're in a theme-aware widget, we're hardcoding certain colors to ensure consistency with your design requirements.
    Color backgroundColor = Theme.of(context).canvasColor; // Adapted for TextField fill color
    Color buttonTextColor = Colors.white; // For button text color

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Keeping AppBar color as blue
        automaticallyImplyLeading: false,
        title: Text(
          'Create List',
          style: TextStyle(color: buttonTextColor),
        ),
        centerTitle: true,
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
                  fillColor: Theme.of(context).cardColor, // Keeping this as was originally
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: TextField(
                maxLines: null,
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'List Description',
                  filled: true,
                  fillColor: Theme.of(context).cardColor, // Keeping this as was originally
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
                        createGroceryList(_listNameController.text, _descriptionController.text);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const ViewListsPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: buttonTextColor, // For button text color
                        backgroundColor: Colors.blue, // Keeping button background as blue
                      ),
                      child: const Text('Create Your List'),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const ViewListsPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: buttonTextColor, // For button text color
                        backgroundColor: Colors.blue, // Keeping button background as blue
                      ),
                      child: const Text('View Lists'),
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

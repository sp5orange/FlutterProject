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
    final items = description
        .split(',')
        .map((e) => e.trim())
        .toList(); // Split by comma and trim spaces

    await FirebaseFirestore.instance.collection('grocery lists').add({
      'CreatedBy': uid,
      'ListName': listName,
      'items': items,
      'sharedWith':
          [], // Initialize with an empty array or as per your requirement
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        title: const Text(
          'Create List',
          style: TextStyle(
            color: Colors.white,
          ),
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
                  fillColor: Colors.white.withOpacity(0.7),
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
                        createGroceryList(_listNameController.text,
                            _descriptionController.text);

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const ViewListsPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.blue,
                      ),
                      child: const Text('Create Your List'),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const ViewListsPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.blue,
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

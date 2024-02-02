import 'package:flutter/material.dart';
import 'package:grocerylist/pages/adduser_page.dart';
import 'package:grocerylist/pages/createaccount_page.dart';
import 'package:grocerylist/pages/createlist_page.dart';
import 'package:grocerylist/pages/login_page.dart';
import 'package:grocerylist/pages/updatelist_page.dart';
import 'package:grocerylist/pages/viewlist_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateList extends StatelessWidget {
  UpdateList({super.key});

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
        title: Row(
          children: [
            Text('Update Your List'),
            Spacer(),
            Text('Sign Out'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Update Your List',
              style: TextStyle(
                fontSize: 30,
                color: Color.fromARGB(255, 255, 255, 255),
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(18.0),
              child: TextField(
                controller: _listNameController,
                decoration: InputDecoration(
                  labelText: 'List Title',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(18.0),
              child: TextField(
                maxLines: null,
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'List Description',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10),
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
                            builder: (context) => ViewListsPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                      ),
                      child: Text('Update Your List'),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ViewListsPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                      ),
                      child: Text('Back'),
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

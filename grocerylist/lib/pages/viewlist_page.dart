import 'package:flutter/material.dart';
import 'package:grocerylist/pages/adduser_page.dart';
import 'package:grocerylist/pages/createaccount_page.dart';
import 'package:grocerylist/pages/createlist_page.dart';
import 'package:grocerylist/pages/login_page.dart';
import 'package:grocerylist/pages/updatelist_page.dart';
import 'package:grocerylist/pages/viewlist_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewListsPage extends StatefulWidget {
  @override
  _ViewListsPageState createState() => _ViewListsPageState();
}

class _ViewListsPageState extends State<ViewListsPage> {
  Future<void> _signOut(BuildContext context) async {
    try {
      // Get the instance of FirebaseAuth
      final FirebaseAuth auth = FirebaseAuth.instance;

      // Call the signOut method
      await auth.signOut();

      // Optionally, navigate the user to the login page or another appropriate page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginPage(), // Replace with your login page
        ),
      );
    } catch (e) {
      // Handle any errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out. Please try again.')),
      );
    }
  }

  Future<List<String>> fetchListNames() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid;
    List<String> listNames = [];

    if (uid == null)
      return listNames; // If no user is logged in, return empty list.

    final querySnapshot = await FirebaseFirestore.instance
        .collection('grocery lists')
        .where('CreatedBy', isEqualTo: uid)
        .get();

    final sharedQuerySnapshot = await FirebaseFirestore.instance
        .collection('grocery lists')
        .where('sharedWith', arrayContains: uid)
        .get();

    for (var doc in querySnapshot.docs) {
      listNames.add(doc.data()['ListName']);
    }

    for (var doc in sharedQuerySnapshot.docs) {
      listNames.add(doc.data()['ListName']);
    }

    return listNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Lists'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<String>>(
              future: fetchListNames(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No lists available.'));
                }

                List<String> lists = snapshot.data!;

                return ListView.builder(
                  itemCount: lists.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(lists[index]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => UpdateList(),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () {
                                // Add delete functionality here.
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            width: 300,
            padding: EdgeInsets.only(bottom: 50, top: 10),
            child: ElevatedButton(
              child: Text('Sign out'),
              onPressed: () => _signOut(context),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

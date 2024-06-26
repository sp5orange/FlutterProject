import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:grocerylist/pages/createlist_page.dart';
import 'package:grocerylist/pages/login_page.dart';
import 'package:grocerylist/pages/updatelist_page.dart';
import 'package:grocerylist/theme_manager.dart'; // Import your ThemeManager class

class ViewListsPage extends StatefulWidget {
  const ViewListsPage({Key? key}) : super(key: key);

  @override
  _ViewListsPageState createState() => _ViewListsPageState();
}

class _ViewListsPageState extends State<ViewListsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<List<String>>? _listNamesFuture;

  @override
  void initState() {
    super.initState();
    _listNamesFuture = fetchListNames();
  }

  Future<List<String>> fetchListNames() async {
    final uid = _auth.currentUser?.uid;
    List<String> listNames = [];

    if (uid == null) return listNames;

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

  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error logging out. Please try again.')),
      );
    }
  }

  Future<String?> _promptForEmail() async {
    String? email;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter user\'s email'),
          content: TextField(
            onChanged: (value) {
              email = value;
            },
            decoration: const InputDecoration(hintText: "Email"),
            keyboardType: TextInputType.emailAddress,
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
    return email;
  }

  Future<void> shareList(String listName) async {
    final email = await _promptForEmail();
    if (email == null || email.isEmpty) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();
      if (userDoc.exists) {
        final uid = userDoc.data()?['uid'];
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('grocery lists')
              .where('ListName', isEqualTo: listName)
              .get()
              .then((querySnapshot) {
            for (var document in querySnapshot.docs) {
              document.reference.update({
                'sharedWith': FieldValue.arrayUnion([uid])
              });
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('List shared successfully!')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user found for that email.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to share list: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeManager>(context, listen: false);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () {
              themeProvider.toggleTheme(themeProvider.themeMode == ThemeMode.light);
            },
          ),
          title: const Text('View Lists'),
          backgroundColor: Colors.blue,
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () => _signOut(context),
              tooltip: 'Sign out',
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<String>>(
                future: _listNamesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No lists available.'));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(snapshot.data![index]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () => shareList(snapshot.data![index]),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => UpdateList(listName: snapshot.data![index]),
                                  ));
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {},
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
              margin: const EdgeInsets.only(left: 250, bottom: 50),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateList()),
                  );
                },
                tooltip: 'Create A New List',
                padding: const EdgeInsets.only(),
                color: Colors.blue,
                iconSize: 60.0,
              )
            )
          ],
        ),
      ),
    );
  }
}

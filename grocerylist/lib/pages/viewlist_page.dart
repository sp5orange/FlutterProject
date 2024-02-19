import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocerylist/pages/createlist_page.dart';
import 'package:grocerylist/pages/login_page.dart';
import 'package:grocerylist/pages/updatelist_page.dart';

class ViewListsPage extends StatefulWidget {
  const ViewListsPage({super.key});

  @override
  _ViewListsPageState createState() => _ViewListsPageState();
}

class _ViewListsPageState extends State<ViewListsPage> {
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

  Future<List<String>> fetchListNames() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid;
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

  Future<void> shareList(String listName) async {
    final email = await _promptForEmail();
    if (email == null || email.isEmpty) return;

    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(email).get();
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

 void _deleteList(String listName) async {
  final bool confirmDelete = await _confirmDeletion();
  if (!confirmDelete) return;

  try {
    await FirebaseFirestore.instance
        .collection('grocery lists')
        .where('ListName', isEqualTo: listName)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('List deleted successfully.')));

    // Trigger a UI update after deletion
    setState(() {
      // This call fetches the updated list names and refreshes the UI
      fetchListNames();
    });
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Failed to delete list: $e')));
  }
}

  Future<bool> _confirmDeletion() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text('Are you sure you want to delete this list?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async => false, // Prevents back button from working
    child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Lists',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        automaticallyImplyLeading: false,
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
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<String>>(
              future: fetchListNames(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No lists available.'));
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
                              icon: const Icon(Icons.share),
                              onPressed: () => shareList(lists[index]),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => UpdateList(listName: lists[index]),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () => _deleteList(lists[index]),
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
            ),
          ),
        ],
      ),
    ));
  }
}

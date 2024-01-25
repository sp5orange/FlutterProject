import 'package:flutter/material.dart';
import 'package:grocerylist/pages/adduser_page.dart';
import 'package:grocerylist/pages/createaccount_page.dart';
import 'package:grocerylist/pages/createlist_page.dart';
import 'package:grocerylist/pages/login_page.dart';
import 'package:grocerylist/pages/updatelist_page.dart';
import 'package:grocerylist/pages/viewlist_page.dart';

class UpdateList extends StatelessWidget {
  UpdateList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text('Create A List'),
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
              'Create Your List',
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                      ),
                      child: Text('Create Your List'),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                      ),
                      child: Text('View Lists'),
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

import 'package:flutter/material.dart';
import 'package:grocerylist/pages/adduser_page.dart';
import 'package:grocerylist/pages/createaccount_page.dart';
import 'package:grocerylist/pages/createlist_page.dart';
import 'package:grocerylist/pages/login_page.dart';
import 'package:grocerylist/pages/updatelist_page.dart';
import 'package:grocerylist/pages/viewlist_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Grocery List',
      home: CreateAccount(),
    );
  }
}

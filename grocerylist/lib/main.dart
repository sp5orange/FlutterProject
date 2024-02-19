import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:grocerylist/pages/login_page.dart';
import 'package:grocerylist/pages/viewlist_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCj1NdSOp6it6yjEfdhe3CbHBcpFeext5k",
            appId: "1:795193426475:web:816bb399d6780c98bde06e",
            messagingSenderId: "795193426475",
            projectId: "grocerylists-f8cb5"));
  }
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCj1NdSOp6it6yjEfdhe3CbHBcpFeext5k",
          appId: "1:795193426475:web:816bb399d6780c98bde06e",
          messagingSenderId: "795193426475",
          projectId: "grocerylists-f8cb5"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Grocery List',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // Get the user
            User? user = snapshot.data;

            // If the user is null, they are not logged in; show LoginPage
            if (user == null) {
              return LoginPage();
            }

            // If the user is not null, they are logged in; show ViewListsPage
            return const ViewListsPage();
          }

          // Show a loading indicator while waiting for the authentication state
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:grocerylist/pages/login_page.dart';
import 'package:grocerylist/pages/viewlist_page.dart';
import 'theme_manager.dart'; 
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCj1NdSOp6it6yjEfdhe3CbHBcpFeext5k",
        appId: "1:795193426475:web:816bb399d6780c98bde06e",
        messagingSenderId: "795193426475",
        projectId: "grocerylists-f8cb5"
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCj1NdSOp6it6yjEfdhe3CbHBcpFeext5k",
        appId: "1:795193426475:web:816bb399d6780c98bde06e",
        messagingSenderId: "795193426475",
        projectId: "grocerylists-f8cb5"
      ),
    );
  }

  // Initialize theme manager and load the theme
  final themeManager = ThemeManager();
  await themeManager.loadTheme();

  runApp(ChangeNotifierProvider(
    create: (_) => themeManager,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeManager>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Grocery List',
      theme: ThemeData.light(), // Define your light theme here
      darkTheme: ThemeData.dark(), // Define your dark theme here
      themeMode: themeProvider.themeMode, // Use themeMode from themeProvider
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;

            if (user == null) {
              return LoginPage();
            }
            return const ViewListsPage();
          }

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

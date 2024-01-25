import 'package:flutter/material.dart';
import 'package:grocerylist/pages/adduser_page.dart';
import 'package:grocerylist/pages/createaccount_page.dart';
import 'package:grocerylist/pages/createlist_page.dart';
import 'package:grocerylist/pages/login_page.dart';
import 'package:grocerylist/pages/updatelist_page.dart';
import 'package:grocerylist/pages/viewlist_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage('images/resized_intense_shopping_pixel_2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Are you ready for an experience?',
                  style: TextStyle(
                    color: Colors.white,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Login Now',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
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
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(18.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
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
                    child: Text('Login'),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateAccount(),
                      ),
                    );
                  },
                  child: Text(
                    "Need To Create An Account? Click Here",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

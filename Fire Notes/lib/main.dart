import 'package:fire_notes/auth/sign_in.dart';
import 'package:fire_notes/auth/sign_up.dart';
import 'package:fire_notes/categories/add.dart';
import 'package:fire_notes/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('===================User is currently signed out!');
      } else {
        print('===================User is signed in!');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.orange,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.orange),
        ),
      ),
      home: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data!.emailVerified) {
          return HomePage();
        }
        return SignIn();
      },
    ),
    debugShowCheckedModeBanner: false,
      routes: {
        "SignUp": (context) => SignUp(),
        "SignIn": (context) => SignIn(),
        "HomePage": (context) => HomePage(),
        "AddCategory": (context) => AddCategory(),
      },
    );
  }
}

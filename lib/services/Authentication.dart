import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:g12/services/SignInPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const Color color = Color(0xffffa493);
    return MaterialApp(
      title: 'Flutter Authentication',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: MaterialColor(color.value, <int, Color>{
          50: color.withOpacity(0.1),
          100: color.withOpacity(0.2),
          200: color.withOpacity(0.3),
          300: color.withOpacity(0.4),
          400: color.withOpacity(0.5),
          500: color.withOpacity(0.6),
          600: color.withOpacity(0.7),
          700: color.withOpacity(0.8),
          800: color.withOpacity(0.9),
          900: color.withOpacity(1.0),
        }),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
              fontSize: 24.0,
            ),
            padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 46.0,
            color: Color(0xffffa493),
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(fontSize: 18.0),
        ),
      ),
      home: LoginPage(),
    );
  }
}

// TODO: 驗證錯誤訊息改為中文
class FireAuth {
  // For registering a new user
  static Future<User?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = userCredential.user;
      await user!.updateDisplayName(name);
      await user.reload();
      user = auth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return Future.error('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        return Future.error('The account already exists for that email.');
      }
    } catch (e) {
      return Future.error(e);
    }

    return user;
  }

  // For signing in an user (have already registered)
  static Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // print('No user found for that email.');
        return Future.error('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        // print('Wrong password provided.');
        return Future.error('Wrong password provided.');
      }
    } catch (e) {
      return Future.error(e);
    }

    return user;
  }

  static Future<User?> refreshUser(User user) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await user.reload();
    User? refreshedUser = auth.currentUser;

    return refreshedUser;
  }
}

class Validator {
  static String? validateName(String? name) {
    if (name == null) {
      return null;
    }

    if (name.isEmpty) {
      return '\u26A0 暱稱不得為空。';
    }

    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null) {
      return null;
    }

    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    if (email.isEmpty) {
      return '\u26A0 電子郵件地址不得為空。';
    } else if (!emailRegExp.hasMatch(email)) {
      return '\u26A0 請輸入有效的電子郵件地址。';
    }

    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null) {
      return null;
    }

    if (password.isEmpty) {
      return '\u26A0 密碼不得為空。';
    } else if (password.length < 6) {
      return '\u26A0 這個密碼太短了。至少要有 6 個字元。';
    }

    return null;
  }
}

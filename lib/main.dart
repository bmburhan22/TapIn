import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'db.dart';
import 'tap_in_home.dart';
import 'signin.dart';
import 'themes.dart';
import 'package:firebase_core/firebase_core.dart';
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TapIn());
}

class TapIn extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    String classID = 'none', id = '', pw = '';

    return FutureBuilder<Map<String, String>>(
      future: DB().getSignInData(),
      builder: (context, signInData) {
        if (signInData.hasData) {
          id = signInData.data!['id']!;
          classID = signInData.data!['classID']!;
          if (classID.isEmpty) classID = 'none';
          pw = signInData.data!['pw']!;
        }
        return FutureBuilder<QueryDocumentSnapshot?>(
            future: DB().signIn(classID, id, pw),
            builder: (context, user) {
              if (user.connectionState == ConnectionState.waiting) {
                return Container();
              }

              return MaterialApp(
                  theme: tapInDarkTheme,
                  home: (!user.hasData || user.data == null)
                      ? SignInPage()
                      : TapInHome(user.data!));
            });
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'tap_in_home.dart';
import 'db.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'TapIn Sign In',
          style: TextStyle(
            
            fontSize: 40,
          ),
        ),
      ),
     */
      body: SignInPageBody(),
    );
  }
}

class SignInPageBody extends StatefulWidget {
  @override
  State<SignInPageBody> createState() => _SignInPageBodyState();
}

class _SignInPageBodyState extends State<SignInPageBody> {
  TextEditingController idTEController = TextEditingController();
  TextEditingController pwTEController = TextEditingController();
  TextEditingController classIDTEController = TextEditingController();

  String id = '';
  String pw = '';
  String classID = '';

  Future<void> signInPressed() async {
    id = idTEController.text.trim();
    pw = pwTEController.text.trim();
    classID = classIDTEController.text.trim();
    try {
      QueryDocumentSnapshot? user = await DB().signIn(classID, id, pw);

      if (user != null) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TapInHome(user)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().substring(11)),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/tapin_logo_vector.svg',
            width: 200,
          ),
          Card(
              child: TextField(
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            controller: classIDTEController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.groups), labelText: 'Class ID'),
          )),
          Card(
              child: TextField(
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            controller: idTEController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.person), labelText: 'ID'),
          )),
          Card(
              child: TextField(
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            controller: pwTEController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock), labelText: 'Password'),
          )),
          ElevatedButton.icon(
            onPressed: () async {
              await signInPressed();
            },
            label: Text("Sign-in"),
            icon: Icon(Icons.login_sharp),
          ),
        ]);
  }
}

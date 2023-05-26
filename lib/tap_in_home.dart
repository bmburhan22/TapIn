import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'signin.dart';
import 'student_view.dart';
import 'teacher_view.dart';
import 'db.dart';

class TapInHome extends StatelessWidget {
  QueryDocumentSnapshot user;
  TapInHome(this.user);
  @override
  Widget build(BuildContext context) {
    Widget view = Container();
    int type = user.get('type') ?? -1;
    if (type == 0) {
      view = TeacherView(user);
    } else if (type == 1) {
      view = FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.size > 0) {
              return StudentView(user, snapshot.data!.docs.first);
            } else {
              return Container();
            }
          },
          future:
              user.reference.parent.where('type', isEqualTo: 0).limit(1).get());
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
            actions: [
              IconButton(
                  onPressed: () async {
                    await DB().writeUserData('', '', '');
                    await Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => SignInPage())));
                  },
                  icon: Icon(Icons.logout_sharp))
            ],
            automaticallyImplyLeading: false,
            title: Text('User: ${user.get("id")??""}',
                    style: TextStyle(fontSize: 40))),
        body: view);
  }
}

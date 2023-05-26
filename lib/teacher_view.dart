import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'student_list.dart';
import 'session_control.dart';

class TeacherView extends StatefulWidget {
  QueryDocumentSnapshot teacher;
  TeacherView(this.teacher);
  @override
  State<TeacherView> createState() => _TeacherViewState();
}

class _TeacherViewState extends State<TeacherView> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(child: StudentList(widget.teacher)),
          SessionController(widget.teacher),
        ]);
  }
}
